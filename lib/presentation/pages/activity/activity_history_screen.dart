import 'package:flutter/material.dart';
import 'package:greengrow_app/presentation/pages/activity/upload_activity_screen.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen.dart';
import 'package:greengrow_app/presentation/pages/device/device_screen.dart';
import 'package:greengrow_app/presentation/widgets/sensor_history_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/config/api_config.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/models/activity_log_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/providers/auth_provider.dart';
import '../sensor/sensor_trend_screen.dart';
import '../../blocs/sensor/sensor_bloc.dart';
import '../../blocs/sensor/sensor_event.dart';
import '../../blocs/sensor/sensor_state.dart';
import 'package:dio/dio.dart';

class ActivityHistoryScreen extends StatefulWidget {
  final int greenhouseId;

  const ActivityHistoryScreen({
    super.key,
    required this.greenhouseId,
  });

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  List<ActivityLog> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      _activities = await ActivityRepository().getActivityLogs(token: token!, greenhouseId: widget.greenhouseId);
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _isLoading = false);
  }

  String _getPhotoUrl(String photoPath) {
    return '${ApiConfig.photoBaseUrl}$photoPath';
  }

  String _getActivityTypeText(String type) {
    switch (type) {
      case 'watering':
        return 'Penyiraman';
      case 'fertilizing':
        return 'Pemupukan';
      case 'pruning':
        return 'Pemangkasan';
      case 'pest_control':
        return 'Pengendalian Hama';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget activityListWidget;
    if (_isLoading) {
      activityListWidget = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      activityListWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            CustomButton(
              onPressed: _loadActivities,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    } else if (_activities.isEmpty) {
      activityListWidget = const Center(
        child: Text('Belum ada aktivitas'),
      );
    } else {
      activityListWidget = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kiri: info aktivitas
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.activityType.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(activity.description),
                        const SizedBox(height: 4),
                        Text(
                          'Tanggal: ' + (activity.createdAt != null ? DateFormat('dd/MM/yyyy').format(activity.createdAt) : '-'),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Kanan: foto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: activity.photoUrl != null && activity.photoUrl!.isNotEmpty
                        ? Image.network(
                            'http://10.0.2.2:3000${activity.photoUrl!}',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 32, color: Colors.grey),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card untuk Riwayat Data Sensor dengan fitur filter
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Riwayat Data Sensor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Informasi Filter Data Sensor'),
                                  content: const SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Filter data sensor berdasarkan:'),
                                        SizedBox(height: 8),
                                        Text('• 24 Jam: Data per jam selama 24 jam terakhir'),
                                        Text('• 7 Hari: Data harian selama seminggu terakhir'),
                                        Text('• 30 Hari: Data harian selama sebulan terakhir'),
                                        Text('• 3 Bulan: Data mingguan selama 3 bulan terakhir'),
                                        Text('• 6 Bulan: Data bulanan selama 6 bulan terakhir'),
                                        Text('• 1 Tahun: Data bulanan selama setahun terakhir'),
                                        SizedBox(height: 8),
                                        Text('Gunakan "Filter Kustom" untuk rentang waktu dan agregasi yang lebih spesifik.'),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(
                        height: 400,
                        child: SensorHistoryWidget(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Card untuk Riwayat Kegiatan (sekarang di bawah)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Kegiatan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 400,
                        child: activityListWidget,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmerDashboardScreen(),
                ),
              );
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
                  builder: (context) => ActivityHistoryScreen(greenhouseId: widget.greenhouseId),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadActivityScreen(greenhouseId: widget.greenhouseId),
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
