import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/sensor_data_model.dart';

class SensorRepository {
  final Dio dio;
  final FlutterSecureStorage? storage;
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  SensorRepository(this.dio, [this.storage]);

  Future<SensorDataModel> getLatestSensorData() async {
    final response = await dio.get('$_baseUrl/sensor/latest');
    return SensorDataModel.fromJson(response.data['data']);
  }

  Future<List<SensorDataModel>> getSensorHistory({String? start, String? end, int? limit}) async {
    final token = await storage?.read(key: 'auth_token');
    final queryParams = <String, dynamic>{};
    if (start != null) queryParams['start'] = start;
    if (end != null) queryParams['end'] = end;
    if (limit != null) queryParams['limit'] = limit;
    final response = await dio.get(
      '$_baseUrl/sensor/history',
      queryParameters: queryParams,
      options: token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
    );
    return (response.data['data'] as List)
        .map((e) => SensorDataModel.fromJson(e))
        .toList();
  }
} 