import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceControlRepository {
  final Dio dio;
  final FlutterSecureStorage storage;
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  DeviceControlRepository(this.dio, this.storage);

  Future<void> controlDevice({
    required String deviceType,
    required String action,
  }) async {
    final token = await storage.read(key: 'auth_token');
    await dio.post(
      '$_baseUrl/device-control',
      data: {
        'device_type': deviceType,
        'action': action,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
} 