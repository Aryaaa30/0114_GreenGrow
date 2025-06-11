import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../blocs/sensor/sensor_bloc.dart';
import '../blocs/sensor/sensor_event.dart';
import '../blocs/sensor/sensor_state.dart';
import '../../data/repositories/sensor_repository.dart';

class SensorHistoryWidget extends StatefulWidget {
  const SensorHistoryWidget({super.key});

  @override
  State<SensorHistoryWidget> createState() => _SensorHistoryWidgetState();
}

class _SensorHistoryWidgetState extends State<SensorHistoryWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  int? _limit = 20;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SensorBloc(SensorRepository(Dio(), const FlutterSecureStorage()))
        ..add(FetchSensorHistory(limit: _limit)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                  child: Text(_startDate == null ? 'Start Date' : _startDate!.toLocal().toString().split(' ')[0]),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                  child: Text(_endDate == null ? 'End Date' : _endDate!.toLocal().toString().split(' ')[0]),
                ),
              ),
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: _limit?.toString(),
                  decoration: const InputDecoration(labelText: 'Limit'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _limit = int.tryParse(v),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  context.read<SensorBloc>().add(FetchSensorHistory(
                        start: _startDate?.toIso8601String().split('T')[0],
                        end: _endDate?.toIso8601String().split('T')[0],
                        limit: _limit,
                      ));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<SensorBloc, SensorState>(
              builder: (context, state) {
                if (state is SensorLoading || state is SensorInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SensorHistoryLoaded) {
                  if (state.history.isEmpty) {
                    return const Center(child: Text('No data found.'));
                  }
                  return ListView.separated(
                    itemCount: state.history.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final d = state.history[i];
                      return ListTile(
                        title: Text('Suhu: ${d.temperature}°C, Kelembapan: ${d.humidity}%'),
                        subtitle: Text('Status: ${d.status}\n${d.recordedAt.toLocal()}'),
                      );
                    },
                  );
                } else if (state is SensorError) {
                  return Text('Error: ${state.message}');
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
} 