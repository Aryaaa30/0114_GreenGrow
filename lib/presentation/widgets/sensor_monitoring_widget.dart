import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/sensor_repository.dart';
import '../blocs/sensor/sensor_bloc.dart';
import '../blocs/sensor/sensor_event.dart';
import '../blocs/sensor/sensor_state.dart';

class SensorMonitoringWidget extends StatefulWidget {
  const SensorMonitoringWidget({super.key});

  @override
  State<SensorMonitoringWidget> createState() => _SensorMonitoringWidgetState();
}

class _SensorMonitoringWidgetState extends State<SensorMonitoringWidget> {
  late final SensorBloc _sensorBloc;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sensorBloc = SensorBloc(SensorRepository(Dio()));
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData());
  }

  void _fetchData() {
    _sensorBloc.add(FetchLatestSensorData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _sensorBloc,
      child: BlocBuilder<SensorBloc, SensorState>(
        builder: (context, state) {
          if (state is SensorLoading || state is SensorInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SensorLoaded) {
            final data = state.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suhu: ${data.temperature}°C', style: const TextStyle(fontSize: 18)),
                Text('Kelembapan: ${data.humidity}%', style: const TextStyle(fontSize: 18)),
                Text('Status: ${data.status}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Update: ${data.recordedAt.toLocal()}'),
              ],
            );
          } else if (state is SensorError) {
            return Text('Error: ${state.message}');
          }
          return const SizedBox();
        },
      ),
    );
  }
} 