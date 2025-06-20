import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../widgets/sensor_monitoring_widget.dart';
import '../../widgets/notification_badge.dart';
import '../../blocs/device_control/device_control_bloc.dart';
import '../../blocs/device_control/device_control_event.dart';
import '../../blocs/device_control/device_control_state.dart';
import '../../../data/repositories/device_control_repository.dart';
import '../activity/activity_history_screen.dart';
import '../activity/upload_activity_screen.dart';
import '../sensor/sensor_trend_screen.dart';
import '../notification/notification_screen.dart';
import '../device/device_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;
  bool isAutomationOn = false;
  String blowerStatus = 'OFF';
  String sprayerStatus = 'OFF';
  double temperature = 0.0;
  double humidity = 0.0;
  String sensorStatus = '-';
  // Ganti dengan alamat backend kamu
  final String baseUrl = 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    // Load unread notification count when dashboard is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .loadUnreadCount();
    });
    fetchAutomationStatus();
    fetchLatestSensorData();
  }

  Future<void> fetchAutomationStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/api/automation'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        isAutomationOn = data['automation_status'] == 'ON' ||
            data['is_automation_enabled'] == true;
        blowerStatus = data['blower_status'] ?? 'OFF';
        sprayerStatus = data['sprayer_status'] ?? 'OFF';
      });
    }
  }

  Future<void> fetchLatestSensorData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/sensors/latest'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['temperature']?.toDouble() ?? 0.0;
          humidity = data['humidity']?.toDouble() ?? 0.0;
          sensorStatus = data['status'] ?? '-';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          sensorStatus = 'Gagal mengambil data sensor (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        sensorStatus = 'Gagal mengambil data sensor (error: $e)';
      });
    }
  }

  Future<void> setAutomationMode(bool value) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/automation/mode'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'is_automation_enabled': value}),
    );
    if (response.statusCode == 200) {
      setState(() {
        isAutomationOn = value;
      });
      fetchAutomationStatus();
    }
  }

  Future<void> setDeviceStatus({String? blower, String? sprayer}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/automation/device'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        if (blower != null) 'blower_status': blower,
        if (sprayer != null) 'sprayer_status': sprayer,
      }),
    );
    if (response.statusCode == 200) {
      fetchAutomationStatus();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on selected index
    switch (index) {
      case 0:
        // Home - already on dashboard, do nothing
        break;
      case 1:
        // Device Control - navigate to device_screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DeviceScreen(),
          ),
        );
        break;
      case 2:
        // History - navigate to activity history
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityHistoryScreen(
              greenhouseId: 1, // Using the same hardcoded value
            ),
          ),
        );
        break;
      case 3:
        // Aktivitas - navigate to upload activity screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadActivityScreen(
              greenhouseId: 1, // Using the same hardcoded value
            ),
          ),
        );
        break;
      case 4:
        // Settings - navigate to settings or show menu
        _showSettingsMenu();
        break;
    }
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final authProvider = Provider.of<AuthProvider>(context);
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Pengaturan'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Bantuan'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to help screen
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Keluar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    const int greenhouseId = 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Petani'),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await fetchAutomationStatus();
                await fetchLatestSensorData();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Automation Switch
                  Card(
                    child: ListTile(
                      title: const Text('Automation'),
                      subtitle: Text(
                          isAutomationOn ? 'ON (Otomatis)' : 'OFF (Manual)'),
                      trailing: Switch(
                        value: isAutomationOn,
                        onChanged: (value) => setAutomationMode(value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sensor Data
                  Card(
                    child: ListTile(
                      title: const Text('Suhu & Kelembapan'),
                      subtitle: Text(
                          'Suhu: ${temperature.toStringAsFixed(1)}°C\nKelembapan: ${humidity.toStringAsFixed(1)}%'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status Sensor
                  Card(
                    child: ListTile(
                      title: const Text('Status Kondisi'),
                      subtitle: Text(sensorStatus),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Device Status & Manual Control
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Blower'),
                          subtitle: Text('Status: $blowerStatus'),
                          trailing: ElevatedButton(
                            onPressed: isAutomationOn
                                ? null
                                : () => setDeviceStatus(
                                    blower:
                                        blowerStatus == 'ON' ? 'OFF' : 'ON'),
                            child: Text(
                                blowerStatus == 'ON' ? 'Matikan' : 'Nyalakan'),
                          ),
                        ),
                        ListTile(
                          title: const Text('Sprayer'),
                          subtitle: Text('Status: $sprayerStatus'),
                          trailing: ElevatedButton(
                            onPressed: isAutomationOn
                                ? null
                                : () => setDeviceStatus(
                                    sprayer:
                                        sprayerStatus == 'ON' ? 'OFF' : 'ON'),
                            child: Text(
                                sprayerStatus == 'ON' ? 'Matikan' : 'Nyalakan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ...widget lain seperti histori, grafik, dsb sesuai kebutuhan...
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
