import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/weather_service.dart';
import '../model/chart_data.dart';
import 'weather_event.dart';
import 'weather_state.dart';

/// BLoC der håndterer vejr-relateret business logic
/// 
/// WeatherBloc lytter til events (LoadWeatherData, RefreshWeatherData)
/// og emitter states (WeatherLoading, WeatherLoaded, WeatherError)
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _weatherService;

  WeatherBloc({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService(),
        super(const WeatherInitial()) {
    // Registrer event handlers
    on<LoadWeatherData>(_onLoadWeatherData);
    on<RefreshWeatherData>(_onRefreshWeatherData);
  }

  /// Handler for LoadWeatherData event
  Future<void> _onLoadWeatherData(
    LoadWeatherData event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    try {
      final weatherData = await _weatherService.getWeatherForecast();
      final chartData = ChartData.fromWeatherData(weatherData);

      emit(WeatherLoaded(
        weatherData: weatherData,
        chartData: chartData,
      ));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  /// Handler for RefreshWeatherData event
  Future<void> _onRefreshWeatherData(
    RefreshWeatherData event,
    Emitter<WeatherState> emit,
  ) async {
    // Bruger samme logik som LoadWeatherData
    await _onLoadWeatherData(const LoadWeatherData(), emit);
  }
}

