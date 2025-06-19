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
        final data = await repository.getLatestSensorDataWithCache();
        emit(SensorLoaded(data));
      } catch (e) {
        emit(SensorError(e.toString()));
      }
    });
    on<FetchSensorHistory>((event, emit) async {
      emit(SensorLoading());
      try {
        final history = await repository.getSensorHistoryWithCache();
        emit(SensorHistoryLoaded(history));
      } catch (e) {
        emit(SensorError(e.toString()));
      }
    });
    on<FetchAllSensors>((event, emit) async {
      emit(SensorLoading());
      try {
        final data = await repository.getAllSensors();
        emit(SensorHistoryLoaded(data));
      } catch (e) {
        emit(SensorError(e.toString()));
      }
    });
  }
}
