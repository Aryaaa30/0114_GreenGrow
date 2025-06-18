import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../services/notification_service.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  String? _userId;
  String? _userRole;

  String? get token => _token;
  String? get userId => _userId;
  String? get userRole => _userRole;
  bool get isAuthenticated => _token != null;

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
    notifyListeners();
  }

  Future<void> setUserId(String userId) async {
    _userId = userId;
    await _storage.write(key: 'userId', value: userId);
    notifyListeners();
  }

  Future<void> setUserRole(String role) async {
    _userRole = role;
    await _storage.write(key: 'userRole', value: role);
    notifyListeners();
  }

  Future<void> loadStoredData() async {
    _token = await _storage.read(key: 'token');
    _userId = await _storage.read(key: 'userId');
    _userRole = await _storage.read(key: 'userRole');
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userRole = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  Future<void> updateFcmTokenToBackend() async {
    if (_token == null) return;
    final fcmToken = await NotificationService.getFcmToken();
    if (fcmToken != null) {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/profile/fcm-token'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: '{"fcm_token": "$fcmToken"}',
      );
    }
  }
}
