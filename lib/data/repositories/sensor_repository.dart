import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/sensor_data_model.dart';
import '../local/sensor_local_db.dart';
import '../local/sync_queue_db.dart';

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

  Future<SensorDataModel> getLatestSensorDataWithCache() async {
    try {
      final data = await getLatestSensorData();
      await SensorLocalDb.insertSensorData(data);
      return data;
    } catch (_) {
      final local = await SensorLocalDb.getAllSensorData();
      if (local.isNotEmpty) return local.first;
      rethrow;
    }
  }

  Future<List<SensorDataModel>> getSensorHistoryWithCache() async {
    try {
      final history = await getSensorHistory();
      for (final d in history) {
        await SensorLocalDb.insertSensorData(d);
      }
      return history;
    } catch (_) {
      return await SensorLocalDb.getAllSensorData();
    }
  }

  Future<void> syncQueueToBackend() async {
    final queue = await SyncQueueDb.getQueue();
    for (final data in queue) {
      try {
        await dio.post(
          '$_baseUrl/sensor',
          data: {
            'temperature': data.temperature,
            'humidity': data.humidity,
            'status': data.status,
            'recorded_at': data.recordedAt.toIso8601String(),
          },
        );
      } catch (_) {
        // Jika gagal, biarkan tetap di queue
        return;
      }
    }
    await SyncQueueDb.clearQueue();
  }
} 