import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../blocs/sensor/sensor_bloc.dart';
import '../blocs/sensor/sensor_event.dart';
import '../blocs/sensor/sensor_state.dart';
import '../../data/repositories/sensor_repository.dart';
import '../../data/models/sensor_data_model.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorHistoryWidget extends StatefulWidget {
  const SensorHistoryWidget({super.key});

  @override
  State<SensorHistoryWidget> createState() => _SensorHistoryWidgetState();
}

class _SensorHistoryWidgetState extends State<SensorHistoryWidget>
    with SingleTickerProviderStateMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  int? _limit = 100;
  String _groupBy = 'hour'; // Default grouping: hour, day, week, month, year
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set default date range to last 24 hours
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(hours: 24));

    // Fetch data with default parameters when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyPresetFilter(String preset) {
    final now = DateTime.now();

    setState(() {
      _endDate = now;

      switch (preset) {
        case '24h':
          _startDate = now.subtract(const Duration(hours: 24));
          _groupBy = 'hour';
          break;
        case '7d':
          _startDate = now.subtract(const Duration(days: 7));
          _groupBy = 'day';
          break;
        case '30d':
          _startDate = now.subtract(const Duration(days: 30));
          _groupBy = 'day';
          break;
        case '3m':
          _startDate = DateTime(now.year, now.month - 3, now.day);
          _groupBy = 'week';
          break;
        case '6m':
          _startDate = DateTime(now.year, now.month - 6, now.day);
          _groupBy = 'month';
          break;
        case '1y':
          _startDate = DateTime(now.year - 1, now.month, now.day);
          _groupBy = 'month';
          break;
      }
    });

    // Trigger data fetch with new filter
    _fetchData();
  }

  void _fetchData() {
    if (_startDate != null && _endDate != null) {
      print('Fetching data with parameters:');
      print('Start date: ${_startDate!.toIso8601String()}');
      print('End date: ${_endDate!.toIso8601String()}');
      print('Group by: $_groupBy');
      print('Limit: $_limit');

      // Make sure end date is at the end of the day (23:59:59)
      final endDateWithTime =
          DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);

      context.read<SensorBloc>().add(FetchSensorHistory(
            start: _startDate!.toIso8601String(),
            end: endDateWithTime.toIso8601String(),
            limit: _limit,
            groupBy: _groupBy,
          ));
    } else {
      // Show error message if dates are not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal mulai dan akhir'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<FlSpot> _getTemperatureSpots(List<SensorDataModel> data) {
    // Sort data by recorded date to ensure proper chart display
    final sortedData = List<SensorDataModel>.from(data)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return sortedData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperature);
    }).toList();
  }

  List<FlSpot> _getHumiditySpots(List<SensorDataModel> data) {
    // Sort data by recorded date to ensure proper chart display
    final sortedData = List<SensorDataModel>.from(data)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return sortedData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.humidity);
    }).toList();
  }

  String _formatDateTime(DateTime dateTime) {
    switch (_groupBy) {
      case 'hour':
        return DateFormat('HH:00, dd MMM').format(dateTime);
      case 'day':
        return DateFormat('dd MMM').format(dateTime);
      case 'week':
        return 'W${(dateTime.day / 7).ceil()}, ${DateFormat('MMM').format(dateTime)}';
      case 'month':
        return DateFormat('MMM yyyy').format(dateTime);
      case 'year':
        return dateTime.year.toString();
      default:
        return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SensorBloc(SensorRepository(Dio(), const FlutterSecureStorage()))
            ..add(FetchSensorHistory(
              start: _startDate?.toIso8601String().split('T')[0],
              end: _endDate?.toIso8601String().split('T')[0],
              limit: _limit,
              groupBy: _groupBy,
            )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter options
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('24 Jam'),
                selected: _groupBy == 'hour' &&
                    _startDate != null &&
                    _startDate!.difference(_endDate!).inHours.abs() == 24,
                onSelected: (_) => _applyPresetFilter('24h'),
              ),
              FilterChip(
                label: const Text('7 Hari'),
                selected: _groupBy == 'day' &&
                    _startDate != null &&
                    _startDate!.difference(_endDate!).inDays.abs() == 7,
                onSelected: (_) => _applyPresetFilter('7d'),
              ),
              FilterChip(
                label: const Text('30 Hari'),
                selected: _groupBy == 'day' &&
                    _startDate != null &&
                    _startDate!.difference(_endDate!).inDays.abs() == 30,
                onSelected: (_) => _applyPresetFilter('30d'),
              ),
              FilterChip(
                label: const Text('3 Bulan'),
                selected: _groupBy == 'week' &&
                    _startDate != null &&
                    (_startDate!.difference(_endDate!).inDays.abs() ~/ 30) == 3,
                onSelected: (_) => _applyPresetFilter('3m'),
              ),
              FilterChip(
                label: const Text('6 Bulan'),
                selected: _groupBy == 'month' &&
                    _startDate != null &&
                    (_startDate!.difference(_endDate!).inDays.abs() ~/ 30) == 6,
                onSelected: (_) => _applyPresetFilter('6m'),
              ),
              FilterChip(
                label: const Text('1 Tahun'),
                selected: _groupBy == 'month' &&
                    _startDate != null &&
                    (_startDate!.difference(_endDate!).inDays.abs() ~/ 365) ==
                        1,
                onSelected: (_) => _applyPresetFilter('1y'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Custom date range
          ExpansionTile(
            title: const Text('Filter Kustom'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null)
                            setState(() => _startDate = picked);
                        },
                        label: Text(_startDate == null
                            ? 'Mulai'
                            : DateFormat('dd/MM/yyyy').format(_startDate!)),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => _endDate = picked);
                        },
                        label: Text(_endDate == null
                            ? 'Akhir'
                            : DateFormat('dd/MM/yyyy').format(_endDate!)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Agregasi'),
                        value: _groupBy,
                        items: const [
                          DropdownMenuItem(
                              value: 'hour', child: Text('Per Jam')),
                          DropdownMenuItem(
                              value: 'day', child: Text('Per Hari')),
                          DropdownMenuItem(
                              value: 'week', child: Text('Per Minggu')),
                          DropdownMenuItem(
                              value: 'month', child: Text('Per Bulan')),
                          DropdownMenuItem(
                              value: 'year', child: Text('Per Tahun')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _groupBy = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: _limit?.toString(),
                        decoration: const InputDecoration(labelText: 'Limit'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) =>
                            setState(() => _limit = int.tryParse(v)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Terapkan Filter'),
                  onPressed: _fetchData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tab bar for chart/list view
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.show_chart), text: 'Grafik'),
              Tab(icon: Icon(Icons.list), text: 'Daftar'),
            ],
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Chart View
                BlocBuilder<SensorBloc, SensorState>(
                  builder: (context, state) {
                    if (state is SensorLoading || state is SensorInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SensorHistoryLoaded) {
                      if (state.history.isEmpty) {
                        return const Center(child: Text('Tidak ada data.'));
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 &&
                                              value.toInt() <
                                                  state.history.length) {
                                            // Sort data by recorded date
                                            final sortedData =
                                                List<SensorDataModel>.from(
                                                    state.history)
                                                  ..sort((a, b) => a.recordedAt
                                                      .compareTo(b.recordedAt));

                                            // Show fewer labels for better readability
                                            final interval =
                                                (sortedData.length / 4).ceil();
                                            if (value.toInt() % interval == 0) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  _formatDateTime(
                                                      sortedData[value.toInt()]
                                                          .recordedAt),
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                ),
                                              );
                                            }
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  lineBarsData: [
                                    // Temperature line
                                    LineChartBarData(
                                      spots:
                                          _getTemperatureSpots(state.history),
                                      isCurved: true,
                                      color: Colors.red,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                    // Humidity line
                                    LineChartBarData(
                                      spots: _getHumiditySpots(state.history),
                                      isCurved: true,
                                      color: Colors.blue,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('Suhu (°C)'),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('Kelembapan (%)'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else if (state is SensorError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchData,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),

                // List View
                BlocBuilder<SensorBloc, SensorState>(
                  builder: (context, state) {
                    if (state is SensorLoading || state is SensorInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SensorHistoryLoaded) {
                      if (state.history.isEmpty) {
                        return const Center(child: Text('Tidak ada data.'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: state.history.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, i) {
                          final d = state.history[i];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDateTime(d.recordedAt),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: d.status == 'Normal'
                                              ? Colors.green
                                              : Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          d.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.thermostat,
                                                color: Colors.red),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${d.temperature.toStringAsFixed(1)}°C',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.water_drop,
                                                color: Colors.blue),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${d.humidity.toStringAsFixed(1)}%',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is SensorError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchData,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
