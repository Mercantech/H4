import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_forecast.dart';
import '../../core/constants/api_constants.dart';

class WeatherService {
  Future<List<WeatherForecast>> getWeatherForecast() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.weatherForecastUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => WeatherForecast.fromJson(json)).toList();
      } else {
        throw Exception('Fejl ved hentning af vejrdata: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netværksfejl: $e');
    }
  }
} 