import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/presentation/pages/activity/activity_history_screen.dart';
import 'package:greengrow_app/presentation/pages/activity/upload_activity_screen.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen.dart';
import '../../blocs/device_control/device_control_bloc.dart';
import '../../blocs/device_control/device_control_event.dart';
import '../../blocs/device_control/device_control_state.dart';
import '../../../data/repositories/device_control_repository.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol & Status Perangkat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocProvider(
              create: (context) => DeviceControlBloc(
                DeviceControlRepository(Dio(), const FlutterSecureStorage()),
              ),
              child: BlocConsumer<DeviceControlBloc, DeviceControlState>(
                listener: (context, state) {
                  if (state is DeviceControlSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Perintah berhasil dikirim!')),
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
                          const Text('Kontrol Perangkat',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
                                                  action: 'ON'),
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
                                                  action: 'OFF'),
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
                                                  action: 'ON'),
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
                                                  action: 'OFF'),
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
                    Text('Status Perangkat',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Index untuk tab Control
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FarmerDashboardScreen(),
                ),
              );
              break;
            case 1:
              // Sudah di halaman ini
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityHistoryScreen(greenhouseId: 1),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadActivityScreen(greenhouseId: 1),
                ),
              );
              break;
            case 4:
              // Settings, bisa tampilkan modal atau halaman settings
              break;
          }
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.developer_board),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_photo_alternate),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
