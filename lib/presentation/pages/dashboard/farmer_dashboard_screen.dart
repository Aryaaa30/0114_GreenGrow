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
import '../settings/settings_screen.dart';

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

  SensorRealtimeData? previousSensorData;
  SensorRealtimeData? currentSensorData;
  SensorForecastData? forecastSensorData;
  bool isRealtimeLoading = true;
  String realtimeError = '';

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
    fetchRealtimeSensorData();
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
      // Perbaiki parsing sesuai struktur respons backend
      final automationData = data['data'] ?? data;
      setState(() {
        isAutomationOn = automationData['is_automation_enabled'] == true;
        blowerStatus = automationData['blower_status'] ?? 'OFF';
        sprayerStatus = automationData['sprayer_status'] ?? 'OFF';
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
          // Jika gagal, coba ambil status dari currentSensorData
          if (currentSensorData != null) {
            sensorStatus =
                'Suhu:  ${currentSensorData?.temperature?.toStringAsFixed(1) ?? '-'}°C, Kelembapan:  ${currentSensorData?.humidity?.toStringAsFixed(1) ?? '-'}%';
          } else {
            sensorStatus =
                'Gagal mengambil data sensor (${response.statusCode})';
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        // Jika error, coba ambil status dari currentSensorData
        if (currentSensorData != null) {
          sensorStatus =
              'Suhu:  ${currentSensorData?.temperature?.toStringAsFixed(1) ?? '-'}°C, Kelembapan:  ${currentSensorData?.humidity?.toStringAsFixed(1) ?? '-'}%';
        } else {
          sensorStatus = 'Gagal mengambil data sensor (error: $e)';
        }
      });
    }
  }

  Future<void> fetchRealtimeSensorData() async {
    setState(() {
      isRealtimeLoading = true;
      realtimeError = '';
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final response = await http.get(
        Uri.parse('$baseUrl/api/sensors/realtime'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic>? d = data['data'];
        setState(() {
          previousSensorData = SensorRealtimeData.fromJson(d?['previous']);
          currentSensorData = SensorRealtimeData.fromJson(d?['current']);
          forecastSensorData = SensorForecastData.fromJson(d?['forecast']);
          isRealtimeLoading = false;
        });
      } else {
        setState(() {
          isRealtimeLoading = false;
          realtimeError =
              'Gagal mengambil data realtime (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        isRealtimeLoading = false;
        realtimeError = 'Gagal mengambil data realtime (error: $e)';
      });
    }
  }

  Future<void> setAutomationMode(bool value) async {
    setState(() {
      isAutomationLoading = true;
      isAutomationOn = value; // Update state lokal agar UI langsung berubah
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
        // Jika gagal, kembalikan ke state sebelumnya
        setState(() {
          isAutomationOn = !value;
        });
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
      // Jika error, kembalikan ke state sebelumnya
      setState(() {
        isAutomationOn = !value;
      });
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

    switch (index) {
      case 0:
        // Home - already on dashboard, do nothing
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceScreen(),
          ),
        );
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(),
          ),
        );
        break;
    }
  }

  // Fungsi untuk menentukan status suhu
  String _getTemperatureStatus(double? temp) {
    if (temp == null) return '-';
    if (temp >= 28.0) return 'Terlalu Panas';
    if (temp <= 20.0) return 'Terlalu Dingin';
    return 'Normal';
  }

  // Fungsi untuk menentukan status kelembapan
  String _getHumidityStatus(double? hum) {
    if (hum == null) return '-';
    if (hum >= 80.0) return 'Terlalu Lembap';
    if (hum <= 50.0) return 'Terlalu Kering';
    return 'Normal';
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
                await fetchRealtimeSensorData();
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
                  // Card Suhu & Kelembapan Gabung
                  _SensorCombinedCard(
                    previousTemp: previousSensorData?.temperature,
                    currentTemp: currentSensorData?.temperature,
                    forecastTemp: forecastSensorData?.temperature,
                    previousHum: previousSensorData?.humidity,
                    currentHum: currentSensorData?.humidity,
                    forecastHum: forecastSensorData?.humidity,
                  ),
                  const SizedBox(height: 16),
                  // Status Sensor
                  Card(
                    child: ListTile(
                      title: const Text('Status Kondisi Suhu'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Suhu: ${currentSensorData?.temperature?.toStringAsFixed(1) ?? '-'}°C'),
                          Text(
                              'Status: ${_getTemperatureStatus(currentSensorData?.temperature)}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status Kondisi Kelembapan
                  Card(
                    child: ListTile(
                      title: const Text('Status Kondisi Kelembapan'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Kelembapan: ${currentSensorData?.humidity?.toStringAsFixed(1) ?? '-'}%'),
                          Text(
                              'Status: ${_getHumidityStatus(currentSensorData?.humidity)}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Real-time Sensor Data Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Realtime Suhu & Kelembapan',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          if (isRealtimeLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (realtimeError.isNotEmpty)
                            Text(realtimeError,
                                style: const TextStyle(color: Colors.red))
                          else ...[
                            _buildSensorRow('Previous', previousSensorData),
                            const Divider(),
                            _buildSensorRow('Current', currentSensorData),
                            const Divider(),
                            _buildForecastRow('Forecast', forecastSensorData),
                          ],
                        ],
                      ),
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

  String _formatTime(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return '-';
    }
  }

  Widget _buildBigSensorCard({
    required String label,
    double? value,
    required String unit,
    String? time,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: Colors.black54),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                value != null ? value.toStringAsFixed(1) : '-',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Center(
              child: Text(
                unit,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Waktu:  0${_formatTime(time)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Courier',
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripleSensorCard({
    required String label,
    double? previous,
    double? current,
    double? forecast,
    required String unit,
    required Color color,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SensorValueColumn(
                  value: previous,
                  unit: unit,
                  label: 'Sebelumnya',
                ),
                _SensorValueColumn(
                  value: current,
                  unit: unit,
                  label: 'Saat Ini',
                ),
                _SensorValueColumn(
                  value: forecast,
                  unit: unit,
                  label: 'Prediksi',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow(String label, SensorRealtimeData? data) {
    if (data == null || (data.temperature == null && data.humidity == null)) {
      return Text('$label: Belum ada data');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          'Suhu: ${data.temperature?.toStringAsFixed(1) ?? '-'}°C\nKelembapan: ${data.humidity?.toStringAsFixed(1) ?? '-'}%\nWaktu: ${data.recordedAt ?? '-'}',
        ),
      ],
    );
  }

  Widget _buildForecastRow(String label, SensorForecastData? data) {
    if (data == null || (data.temperature == null && data.humidity == null)) {
      return Text('$label: Belum ada data prediksi');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          'Suhu: ${data.temperature?.toStringAsFixed(1) ?? '-'}°C\nKelembapan: ${data.humidity?.toStringAsFixed(1) ?? '-'}%',
        ),
      ],
    );
  }
}

class SensorRealtimeData {
  final double? temperature;
  final double? humidity;
  final String? recordedAt;

  SensorRealtimeData({this.temperature, this.humidity, this.recordedAt});

  factory SensorRealtimeData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SensorRealtimeData();
    return SensorRealtimeData(
      temperature: _parseToDouble(json['temperature']),
      humidity: _parseToDouble(json['humidity']),
      recordedAt: json['recorded_at'] as String?,
    );
  }
}

class SensorForecastData {
  final double? temperature;
  final double? humidity;

  SensorForecastData({this.temperature, this.humidity});

  factory SensorForecastData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SensorForecastData();
    return SensorForecastData(
      temperature: _parseToDouble(json['temperature']),
      humidity: _parseToDouble(json['humidity']),
    );
  }
}

// Helper untuk parsing string/num ke double
double? _parseToDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

// Tambahkan di bawah semua class State
class _SensorValueColumn extends StatelessWidget {
  final double? value;
  final String unit;
  final String label;
  const _SensorValueColumn(
      {this.value, required this.unit, required this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value != null ? value!.toStringAsFixed(1) : '-',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Courier',
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SensorCombinedCard extends StatelessWidget {
  final double? previousTemp;
  final double? currentTemp;
  final double? forecastTemp;
  final double? previousHum;
  final double? currentHum;
  final double? forecastHum;
  const _SensorCombinedCard({
    this.previousTemp,
    this.currentTemp,
    this.forecastTemp,
    this.previousHum,
    this.currentHum,
    this.forecastHum,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Kolom Suhu
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Suhu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SensorVerticalValue(
                    previous: previousTemp,
                    current: currentTemp,
                    forecast: forecastTemp,
                    unit: '°C',
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 90,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            // Kolom Kelembapan
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Kelembapan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SensorVerticalValue(
                    previous: previousHum,
                    current: currentHum,
                    forecast: forecastHum,
                    unit: '%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorVerticalValue extends StatelessWidget {
  final double? previous;
  final double? current;
  final double? forecast;
  final String unit;
  const _SensorVerticalValue({
    this.previous,
    this.current,
    this.forecast,
    required this.unit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous (atas)
        Text(
          previous != null ? previous!.toStringAsFixed(1) : '-',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
            fontFamily: 'Courier',
          ),
        ),
        // Current (tengah, besar)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              current != null ? current!.toStringAsFixed(1) : '-',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Courier',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                unit,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Forecast (bawah)
        Text(
          forecast != null ? forecast!.toStringAsFixed(1) : '-',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }
}
