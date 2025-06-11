import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/sensor_monitoring_widget.dart';
import '../../blocs/automation_threshold/automation_threshold_bloc.dart';
import '../../blocs/automation_threshold/automation_threshold_event.dart';
import '../../blocs/automation_threshold/automation_threshold_state.dart';
import '../../../data/repositories/automation_threshold_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedParameter = 'temperature';
  String _selectedDevice = 'blower';
  double? _minValue;
  double? _maxValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocProvider(
              create: (context) => AutomationThresholdBloc(
                AutomationThresholdRepository(Dio(), const FlutterSecureStorage()),
              )..add(FetchThresholds()),
              child: BlocConsumer<AutomationThresholdBloc, AutomationThresholdState>(
                listener: (context, state) {
                  if (state is AutomationThresholdSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Konfigurasi berhasil disimpan!')),
                    );
                  } else if (state is AutomationThresholdError) {
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
                          const Text('Konfigurasi Otomatisasi', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text('Parameter:'),
                                    const SizedBox(width: 8),
                                    DropdownButton<String>(
                                      value: _selectedParameter,
                                      items: const [
                                        DropdownMenuItem(value: 'temperature', child: Text('Suhu')),
                                        DropdownMenuItem(value: 'humidity', child: Text('Kelembapan')),
                                      ],
                                      onChanged: (v) {
                                        setState(() => _selectedParameter = v ?? 'temperature');
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    const Text('Device:'),
                                    const SizedBox(width: 8),
                                    DropdownButton<String>(
                                      value: _selectedDevice,
                                      items: const [
                                        DropdownMenuItem(value: 'blower', child: Text('Blower')),
                                        DropdownMenuItem(value: 'sprayer', child: Text('Sprayer')),
                                      ],
                                      onChanged: (v) {
                                        setState(() => _selectedDevice = v ?? 'blower');
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Min Value',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (v) => _minValue = double.tryParse(v),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Max Value',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (v) => _maxValue = double.tryParse(v),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: state is AutomationThresholdLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            context.read<AutomationThresholdBloc>().add(
                                                  UpsertThreshold(
                                                    parameter: _selectedParameter,
                                                    deviceType: _selectedDevice,
                                                    minValue: _minValue,
                                                    maxValue: _maxValue,
                                                  ),
                                                );
                                          }
                                        },
                                  child: state is AutomationThresholdLoading
                                      ? const CircularProgressIndicator()
                                      : const Text('Simpan Konfigurasi'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const Text('Daftar Threshold Saat Ini:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (state is AutomationThresholdLoaded)
                            ...state.thresholds.map((t) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    '${t.parameter} - ${t.deviceType}: min=${t.minValue ?? '-'}, max=${t.maxValue ?? '-'}',
                                  ),
                                )),
                          if (state is AutomationThresholdLoading)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
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
                  children: const [
                    Text('Status Perangkat', style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
} 