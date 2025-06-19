import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/api_config.dart';
import '../../../domain/repositories/activity_repository.dart';
import '../../../domain/models/activity_log.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/providers/auth_provider.dart';
import '../sensor/sensor_trend_screen.dart';

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
  final _repository = ActivityRepository();
  List<ActivityLog> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activities = await _repository.getActivityLogsByGreenhouse(
        widget.greenhouseId,
        authProvider.token!,
      );

      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
              'Error: [31m[1m[4m[0m[0m$_error',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activity.photoPath != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    child: Image.network(
                      _getPhotoUrl(activity.photoPath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getActivityTypeText(activity.activityType),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(activity.description),
                      const SizedBox(height: 8),
                      Text(
                        'Oleh: ${activity.userName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal: ${activity.createdAt}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: activityListWidget),
          const Divider(height: 32),
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
    );
  }
}
