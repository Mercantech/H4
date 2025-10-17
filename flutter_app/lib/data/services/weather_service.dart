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
        // Tjek om response er JSON
        if (response.headers['content-type']?.contains('application/json') != true) {
          throw Exception('Server returnerede ikke JSON data. Status: ${response.statusCode}');
        }
        
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => WeatherForecast.fromJson(json)).toList();
      } else {
        // Prøv at parse fejlmeddelelse
        String errorMessage = 'HTTP ${response.statusCode}';
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (_) {
          // Hvis ikke JSON, brug raw response
          errorMessage = 'Server fejl: ${response.statusCode}\n${response.body}';
        }
        throw Exception('API fejl: $errorMessage');
      }
    } on FormatException catch (e) {
      throw Exception('Data format fejl: Server returnerede ikke gyldig JSON. ${e.message}');
    } on http.ClientException catch (e) {
      throw Exception('Netværksfejl: Kunne ikke forbinde til server. ${e.message}');
    } catch (e) {
      throw Exception('Uventet fejl: $e');
    }
  }
} 