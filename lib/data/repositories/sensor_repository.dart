import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/sensor_data_model.dart';
import '../local/sensor_local_db.dart';
import '../local/sync_queue_db.dart';
import '../../domain/models/sensor_trend.dart';

class SensorRepository {
  final Dio dio;
  final FlutterSecureStorage? storage;
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  SensorRepository(this.dio, [this.storage]);

  Future<SensorDataModel> getLatestSensorData() async {
    final response = await dio.get('$_baseUrl/sensor/latest');
    return SensorDataModel.fromJson(response.data['data']);
  }

  Future<List<SensorDataModel>> getSensorHistory(
      {String? start, String? end, int? limit}) async {
    final token = await storage?.read(key: 'auth_token');
    final queryParams = <String, dynamic>{};
    if (start != null) queryParams['start'] = start;
    if (end != null) queryParams['end'] = end;
    if (limit != null) queryParams['limit'] = limit;
    final response = await dio.get(
      '$_baseUrl/sensor/history',
      queryParameters: queryParams,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
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

  Future<List<SensorTrend>> fetchTrend({
    required String type, // 'temperature' atau 'humidity'
    String range = 'week',
  }) async {
    try {
      final token = await storage?.read(key: 'auth_token');
      final response = await dio.get(
        '$_baseUrl/sensors/trends', // Diperbaiki dari /sensor/trends menjadi /sensors/trends
        queryParameters: {
          'type': type,
          'range': range,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Tambahkan logging untuk debug
      print('Response trend data: ${response.data}');

      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List;
        return data.map((e) => SensorTrend.fromJson(e)).toList();
      } else {
        throw Exception('API error: ${response.data['message']}');
      }
    } catch (e) {
      print('Error fetching trend data: $e');
      rethrow;
    }
  }

  // Helper untuk ambil dua tren sekaligus
  Future<Map<String, List<SensorTrend>>> fetchTemperatureAndHumidityTrends(
      {String range = 'week'}) async {
    try {
      final temp = await fetchTrend(type: 'temperature', range: range);
      final hum = await fetchTrend(type: 'humidity', range: range);
      return {'temperature': temp, 'humidity': hum};
    } catch (e) {
      print('Error in fetchTemperatureAndHumidityTrends: $e');
      rethrow;
    }
  }
}
