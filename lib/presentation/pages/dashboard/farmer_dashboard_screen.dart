import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/sensor_monitoring_widget.dart';
import '../../blocs/device_control/device_control_bloc.dart';
import '../../blocs/device_control/device_control_event.dart';
import '../../blocs/device_control/device_control_state.dart';
import '../../../data/repositories/device_control_repository.dart';

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Monitoring Suhu & Kelembapan', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    SensorMonitoringWidget(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (context) => DeviceControlBloc(
                DeviceControlRepository(Dio(), const FlutterSecureStorage()),
              ),
              child: BlocConsumer<DeviceControlBloc, DeviceControlState>(
                listener: (context, state) {
                  if (state is DeviceControlSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perintah berhasil dikirim!')),
                    );
                  } else if (state is DeviceControlError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kontrol Perangkat', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Blower'),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: state is DeviceControlLoading
                                    ? null
                                    : () {
                                        context.read<DeviceControlBloc>().add(
                                              DeviceControlRequested(
                                                deviceType: 'blower',
                                                action: 'ON',
                                              ),
                                            );
                                      },
                                child: const Text('ON'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: state is DeviceControlLoading
                                    ? null
                                    : () {
                                        context.read<DeviceControlBloc>().add(
                                              DeviceControlRequested(
                                                deviceType: 'blower',
                                                action: 'OFF',
                                              ),
                                            );
                                      },
                                child: const Text('OFF'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Sprayer'),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: state is DeviceControlLoading
                                    ? null
                                    : () {
                                        context.read<DeviceControlBloc>().add(
                                              DeviceControlRequested(
                                                deviceType: 'sprayer',
                                                action: 'ON',
                                              ),
                                            );
                                      },
                                child: const Text('ON'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: state is DeviceControlLoading
                                    ? null
                                    : () {
                                        context.read<DeviceControlBloc>().add(
                                              DeviceControlRequested(
                                                deviceType: 'sprayer',
                                                action: 'OFF',
                                              ),
                                            );
                                      },
                                child: const Text('OFF'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Status Perangkat', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('Blower: OFF'),
                    Text('Sprayer: ON'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 