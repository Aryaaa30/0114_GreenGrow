import 'package:dio/dio.dart';
import '../models/sensor_data_model.dart';

class SensorRepository {
  final Dio dio;
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  SensorRepository(this.dio);

  Future<SensorDataModel> getLatestSensorData() async {
    final response = await dio.get('$_baseUrl/sensor/latest');
    return SensorDataModel.fromJson(response.data['data']);
  }
} 