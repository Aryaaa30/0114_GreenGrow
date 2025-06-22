import 'dart:convert';
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
    return BlocProvider(
      create: (context) => DeviceControlBloc(
        DeviceControlRepository(Dio(), const FlutterSecureStorage()),
      )..add(DeviceControlFetchStatus()),
      child: BlocConsumer<DeviceControlBloc, DeviceControlState>(
        listener: (context, state) {
          if (state is DeviceControlStatus && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor:
                    state.success == false ? Colors.red : Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is DeviceControlError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          bool blowerOn = false;
          bool sprayerOn = false;
          bool isAutomationEnabled = false;
          if (state is DeviceControlStatus) {
            blowerOn = state.blowerOn;
            sprayerOn = state.sprayerOn;
            isAutomationEnabled = state.isAutomationEnabled;
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Kontrol & Status Perangkat'),
            ),
            body: state is DeviceControlLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Kontrol Perangkat',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                // Kontrol Blower
                                Row(
                                  children: [
                                    Icon(Icons.air,
                                        color: blowerOn
                                            ? Colors.green
                                            : Colors.grey),
                                    const SizedBox(width: 8),
                                    const Text('Blower'),
                                    const Spacer(),
                                    Switch(
                                      value: blowerOn,
                                      onChanged: (isOn) {
                                        if (isAutomationEnabled) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Matikan mode automation untuk kontrol manual blower.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        context.read<DeviceControlBloc>().add(
                                              DeviceControlRequested(
                                                  deviceType: 'blower',
                                                  action: isOn ? 'ON' : 'OFF'),
                                            );
                                      },
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.grey,
                                    ),
                                    Text(
                                      blowerOn ? 'ON' : 'OFF',
                                      style: TextStyle(
                                        color: blowerOn
                                            ? Colors.green
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Kontrol Sprayer
                                Row(
                                  children: [
                                    Icon(Icons.opacity,
                                        color: sprayerOn
                                            ? Colors.green
                                            : Colors.grey),
                                    const SizedBox(width: 8),
                                    const Text('Sprayer'),
                                    const Spacer(),
                                    Switch(
                                      value: sprayerOn,
                                      onChanged: (isOn) {
                                        if (isAutomationEnabled) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Matikan mode automation untuk kontrol manual sprayer.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        context.read<DeviceControlBloc>().add(
                                              DeviceControlRequested(
                                                  deviceType: 'sprayer',
                                                  action: isOn ? 'ON' : 'OFF'),
                                            );
                                      },
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.grey,
                                    ),
                                    Text(
                                      sprayerOn ? 'ON' : 'OFF',
                                      style: TextStyle(
                                        color: sprayerOn
                                            ? Colors.green
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Status Perangkat',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Text(
                                    'Automation: 	${isAutomationEnabled ? 'ON' : 'OFF'}',
                                    style: TextStyle(
                                        color: isAutomationEnabled
                                            ? Colors.green
                                            : Colors.red)),
                                Text('Blower: ${blowerOn ? 'ON' : 'OFF'}'),
                                Text('Sprayer: ${sprayerOn ? 'ON' : 'OFF'}'),
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
                        builder: (context) =>
                            ActivityHistoryScreen(greenhouseId: 1),
                      ),
                    );
                    break;
                  case 3:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UploadActivityScreen(greenhouseId: 1),
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
        },
      ),
    );
  }
}
