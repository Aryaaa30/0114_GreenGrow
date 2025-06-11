import 'package:equatable/equatable.dart';

abstract class DeviceControlState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeviceControlInitial extends DeviceControlState {}

class DeviceControlLoading extends DeviceControlState {}

class DeviceControlSuccess extends DeviceControlState {}

class DeviceControlError extends DeviceControlState {
  final String message;
  DeviceControlError(this.message);

  @override
  List<Object?> get props => [message];
} 