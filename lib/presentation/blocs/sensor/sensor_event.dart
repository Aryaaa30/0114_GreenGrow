import 'package:equatable/equatable.dart';

abstract class SensorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchLatestSensorData extends SensorEvent {}

class FetchSensorHistory extends SensorEvent {
  final String? start;
  final String? end;
  final int? limit;
  final String? groupBy; // 'hour', 'day', 'week', 'month', 'year'

  FetchSensorHistory({this.start, this.end, this.limit, this.groupBy});

  @override
  List<Object?> get props => [start, end, limit, groupBy];
}

class FetchAllSensors extends SensorEvent {}
