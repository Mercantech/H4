import 'package:equatable/equatable.dart';
import '../../../data/models/weather_forecast.dart';
import '../model/chart_data.dart';

/// Base class for alle Weather states
abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

/// Initial state når appen starter
class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// State når data bliver hentet
class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

/// State når data er hentet succesfuldt
class WeatherLoaded extends WeatherState {
  final List<WeatherForecast> weatherData;
  final ChartData chartData;

  const WeatherLoaded({
    required this.weatherData,
    required this.chartData,
  });

  @override
  List<Object?> get props => [weatherData, chartData];
}

/// State når der opstår en fejl
class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}

