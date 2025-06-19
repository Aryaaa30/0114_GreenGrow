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
  FetchSensorHistory({this.start, this.end, this.limit});

  @override
  List<Object?> get props => [start, end, limit];
}

class FetchAllSensors extends SensorEvent {}
