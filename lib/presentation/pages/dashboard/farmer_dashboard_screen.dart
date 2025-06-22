import 'dart:convert';
import 'package:greengrow_app/presentation/pages/activity/activity_history_screen.dart';
import 'package:greengrow_app/presentation/pages/activity/upload_activity_screen.dart';
import 'package:greengrow_app/presentation/pages/device/device_screen.dart';
import 'package:greengrow_app/presentation/widgets/notification_badge.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;
  bool isAutomationOn = false;
  bool isAutomationLoading = false;
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final response = await http.get(
      Uri.parse('$baseUrl/api/sensors/automation/status'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        isAutomationOn = data['is_automation_enabled'] == true;
        blowerStatus = data['blower_status'] ?? 'OFF';
        sprayerStatus = data['sprayer_status'] ?? 'OFF';
      });
    } else {
      setState(() {
        isAutomationOn = false;
        blowerStatus = 'OFF';
        sprayerStatus = 'OFF';
      });
    }
  }

  Future<void> fetchLatestSensorData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final response = await http.get(
        Uri.parse('$baseUrl/api/sensors/latest'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
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
    setState(() {
      isAutomationLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final response = await http.put(
        Uri.parse('$baseUrl/api/sensors/automation/mode'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'is_automation_enabled': value}),
      );
      print(
          'Automation PUT response: status=${response.statusCode}, body=${response.body}');
      if (response.statusCode == 200) {
        await Future.delayed(const Duration(milliseconds: 500));
        await fetchAutomationStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Automation berhasil diaktifkan.'
                  : 'Automation berhasil dinonaktifkan.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Sesi login Anda sudah habis atau tidak valid. Silakan login ulang.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        // Optional: redirect ke login
        // Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengubah mode automation (Status: ${response.statusCode})\nBody: ${response.body}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi error: $e',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isAutomationLoading = false;
      });
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
                      trailing: isAutomationLoading
                          ? SizedBox(
                              width: 48,
                              height: 24,
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          : Switch(
                              value: isAutomationOn,
                              onChanged: isAutomationLoading
                                  ? null
                                  : (value) => setAutomationMode(value),
                              activeColor: Colors.white,
                              activeTrackColor: Colors.green,
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey.shade300,
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
