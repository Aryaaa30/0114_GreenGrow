import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/automation_threshold_model.dart';

class AutomationThresholdRepository {
  final Dio dio;
  final FlutterSecureStorage storage;
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  AutomationThresholdRepository(this.dio, this.storage);

  Future<List<AutomationThresholdModel>> getThresholds() async {
    final token = await storage.read(key: 'auth_token');
    final response = await dio.get(
      '$_baseUrl/automation-threshold',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data['thresholds'] as List)
        .map((e) => AutomationThresholdModel.fromJson(e))
        .toList();
  }

  Future<void> upsertThreshold({
    required String parameter,
    required String deviceType,
    double? minValue,
    double? maxValue,
  }) async {
    final token = await storage.read(key: 'auth_token');
    await dio.post(
      '$_baseUrl/automation-threshold',
      data: {
        'parameter': parameter,
        'device_type': deviceType,
        'min_value': minValue,
        'max_value': maxValue,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
} 