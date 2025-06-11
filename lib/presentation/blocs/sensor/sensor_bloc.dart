import 'package:flutter_bloc/flutter_bloc.dart';
import 'sensor_event.dart';
import 'sensor_state.dart';
import '../../../data/repositories/sensor_repository.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final SensorRepository repository;

  SensorBloc(this.repository) : super(SensorInitial()) {
    on<FetchLatestSensorData>((event, emit) async {
      emit(SensorLoading());
      try {
        final data = await repository.getLatestSensorData();
        emit(SensorLoaded(data));
      } catch (e) {
        emit(SensorError(e.toString()));
      }
    });
  }
} 