import 'package:flutter/foundation.dart';
import '../../../data/models/weather_forecast.dart';
import '../../../data/services/weather_service.dart';
import '../model/chart_data.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherState _state = WeatherState.initial;
  List<WeatherForecast> _weatherData = [];
  String _errorMessage = '';
  ChartData? _chartData;

  WeatherState get state => _state;
  List<WeatherForecast> get weatherData => _weatherData;
  String get errorMessage => _errorMessage;
  ChartData? get chartData => _chartData;

  Future<void> loadWeatherData() async {
    _setState(WeatherState.loading);
    
    try {
      final data = await _weatherService.getWeatherForecast();
      _weatherData = data;
      _chartData = ChartData.fromWeatherData(data);
      _setState(WeatherState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(WeatherState.error);
    }
  }

  void _setState(WeatherState newState) {
    _state = newState;
    notifyListeners();
  }

  void refresh() {
    loadWeatherData();
  }
} 