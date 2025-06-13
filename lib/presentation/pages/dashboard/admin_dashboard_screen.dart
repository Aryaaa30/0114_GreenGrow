import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/sensor_monitoring_widget.dart';
import '../../widgets/sensor_history_widget.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
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
                subtitle: const Text('Lihat dan kelola lokasi greenhouse'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement greenhouse map
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur sedang dalam pengembangan'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.people, size: 32),
                title: const Text('Kelola Pengguna'),
                subtitle: const Text('Kelola akun petani dan admin'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement user management
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur sedang dalam pengembangan'),
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
                    Text('Monitoring Suhu & Kelembapan', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    SensorMonitoringWidget(),
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
                    const Text('Konfigurasi Otomatisasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Blower'),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement automation configuration
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur sedang dalam pengembangan'),
                              ),
                            );
                          },
                          child: const Text('Konfigurasi'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Sprayer'),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement automation configuration
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur sedang dalam pengembangan'),
                              ),
                            );
                          },
                          child: const Text('Konfigurasi'),
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
                  children: const [
                    Text('Status Otomatisasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('Blower: Aktif (25°C - 30°C)'),
                    Text('Sprayer: Aktif (60% - 80%)'),
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
                      Text('Riwayat Data Sensor', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Expanded(child: SensorHistoryWidget()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 