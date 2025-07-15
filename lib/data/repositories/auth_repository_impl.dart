import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/data/models/user_model.dart';
import 'package:greengrow_app/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  AuthRepositoryImpl({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
          'remember_me': rememberMe,
        },
      );
      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Login gagal: response tidak valid dari server');
      }
      if (data['status'] == 'success') {
        final innerData = data['data'];
        final token = innerData['token'];
        await _secureStorage.write(key: 'auth_token', value: token);
        return {
          'message': data['message'],
          'token': token,
          'user': UserModel.fromJson(innerData['user']),
        };
      } else {
        throw Exception(data['message'] ?? 'Login gagal');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    String? phoneNumber,
    required int roleId,
    String? profilePhoto,
  }) async {
    try {
      final requestData = {
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'full_name': fullName,
        'phone_number': phoneNumber ?? '',
        'role_id': roleId,
        'profile_photo': profilePhoto,
      };
      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: requestData,
      );
      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Register gagal: response tidak valid dari server');
      }
      if (data['status'] == 'success') {
        // Perbaiki: pastikan return user adalah UserModel, bukan Map
        return {
          'message': data['message'],
          'user': UserModel.fromJson(data['data']),
        };
      } else {
        throw Exception(data['message'] ?? 'Register gagal');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/social-login',
        data: {
          'provider': provider,
          'token': token,
        },
      );

      final authToken = response.data['token'];
      await _secureStorage.write(key: 'auth_token', value: authToken);

      return {
        'message': response.data['message'],
        'token': authToken,
        'user': UserModel.fromJson(response.data['user']),
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        await _dio.post(
          '$_baseUrl/auth/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
      await _secureStorage.delete(key: 'auth_token');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getActivityLogs() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await _dio.get(
        '$_baseUrl/auth/activity-logs',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return List<Map<String, dynamic>>.from(response.data['logs']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> getUserProfile({required String token}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data;
      print('User profile response: ' + data.toString());
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Failed to get user profile: response tidak valid dari server');
      }
      if (data['status'] == 'success') {
        return UserModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get user profile');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response?.data != null) {
      final data = error.response?.data;
      if (data['errors'] != null && data['errors'] is List) {
        final errors = data['errors'] as List;
        final messages = errors.map((e) => e['msg'] ?? e.toString()).join('\n');
        return Exception(messages);
      }
      final message = data['message'] ?? data['error'] ?? data.toString();
      return Exception(message);
    }
    return Exception('Network error occurred');
  }
}
