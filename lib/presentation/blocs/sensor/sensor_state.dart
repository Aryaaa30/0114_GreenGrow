import 'package:equatable/equatable.dart';
import '../../../data/models/sensor_data_model.dart';

abstract class SensorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SensorInitial extends SensorState {}

class SensorLoading extends SensorState {}

class SensorLoaded extends SensorState {
  final SensorDataModel data;
  SensorLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class SensorError extends SensorState {
  final String message;
  SensorError(this.message);

  @override
  List<Object?> get props => [message];
} 