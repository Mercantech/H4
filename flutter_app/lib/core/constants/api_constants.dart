class ApiConstants {
  // Backend API URL 
  static const String baseUrl = 'http://localhost:5197/api';
  
  // Weather endpoints
  static const String weatherForecast = '/WeatherForecast';
  
  // Full URLs
  static String get weatherForecastUrl => '$baseUrl$weatherForecast';
} 