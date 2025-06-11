import 'package:flutter_bloc/flutter_bloc.dart';
import 'device_control_event.dart';
import 'device_control_state.dart';
import '../../../data/repositories/device_control_repository.dart';

class DeviceControlBloc extends Bloc<DeviceControlEvent, DeviceControlState> {
  final DeviceControlRepository repository;

  DeviceControlBloc(this.repository) : super(DeviceControlInitial()) {
    on<DeviceControlRequested>((event, emit) async {
      emit(DeviceControlLoading());
      try {
        await repository.controlDevice(
          deviceType: event.deviceType,
          action: event.action,
        );
        emit(DeviceControlSuccess());
      } catch (e) {
        emit(DeviceControlError(e.toString()));
      }
    });
  }
} 