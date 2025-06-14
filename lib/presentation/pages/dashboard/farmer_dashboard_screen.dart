import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../widgets/sensor_monitoring_widget.dart';
import '../../widgets/sensor_history_widget.dart';
import '../../widgets/notification_badge.dart';
import '../../blocs/device_control/device_control_bloc.dart';
import '../../blocs/device_control/device_control_event.dart';
import '../../blocs/device_control/device_control_state.dart';
import '../../../data/repositories/device_control_repository.dart';
import '../activity/activity_history_screen.dart';
import '../activity/upload_activity_screen.dart';
import '../sensor_trend_screen.dart';
import '../notification/notification_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load unread notification count when dashboard is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // TODO: Get greenhouseId from user data or state management
    const int greenhouseId = 1; // Temporary hardcoded value
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        actions: [
          const NotificationBadge(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.map, size: 32),
                title: const Text('Peta Greenhouse'),
                subtitle: const Text('Lihat lokasi semua greenhouse'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(context, '/greenhouse-map');
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, size: 32),
                title: const Text('Riwayat Aktivitas'),
                subtitle: const Text('Lihat riwayat perawatan tanaman'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityHistoryScreen(
                        greenhouseId: greenhouseId,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_photo_alternate, size: 32),
                title: const Text('Upload Aktivitas'),
                subtitle: const Text('Tambah bukti perawatan tanaman'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadActivityScreen(
                        greenhouseId: greenhouseId,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications, size: 32),
                title: const Text('Notifikasi'),
                subtitle: const Text('Lihat notifikasi suhu dan kelembapan'),
                trailing: Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    return provider.unreadCount > 0
                        ? Badge(
                            label: Text('${provider.unreadCount}'),
                            child: const Icon(Icons.arrow_forward_ios),
                          )
                        : const Icon(Icons.arrow_forward_ios);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  ).then((_) {
                    // Refresh unread count when returning from notification screen
                    Provider.of<NotificationProvider>(context, listen: false)
                        .loadUnreadCount();
                  });
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
                    Text('Monitoring Suhu & Kelembapan',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Text('Status Perangkat',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('Blower: OFF'),
                    Text('Sprayer: ON'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Riwayat Data Sensor',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Expanded(child: SensorHistoryWidget()),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Status Sensor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suhu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.thermostat, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('28°C'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SensorTrendScreen(),
                              ),
                            );
                          },
                          child: const Text('Lihat Grafik'),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kelembapan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('65%'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SensorTrendScreen(),
                              ),
                            );
                          },
                          child: const Text('Lihat Grafik'),
                        ),
                      ],
                    ),
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

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DashboardCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
