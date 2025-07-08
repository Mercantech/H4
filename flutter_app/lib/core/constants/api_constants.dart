class ApiConstants {
  // Backend API URL - juster til jeres backend URL
  static const String baseUrl = '/api';
  
  // Weather endpoints
  static const String weatherForecast = '/WeatherForecast';
  
  // Full URLs
  static String get weatherForecastUrl => '$baseUrl$weatherForecast';
} 