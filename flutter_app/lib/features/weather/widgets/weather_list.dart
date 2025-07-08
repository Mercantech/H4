import 'package:flutter/material.dart';
import '../../../data/models/weather_forecast.dart';
import 'weather_card.dart';
import 'weather_chart.dart';
import '../model/chart_data.dart';

class WeatherList extends StatelessWidget {
  final List<WeatherForecast> forecasts;
  final ChartData? chartData;

  const WeatherList({
    super.key,
    required this.forecasts,
    this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return const Center(
        child: Text(
          'Ingen vejrdata tilgængelig',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Graf øverst
        WeatherChart(forecasts: forecasts, chartData: chartData),
        
        // Liste af vejrforudsigelser
        ...forecasts.map((forecast) => WeatherCard(forecast: forecast)),
      ],
    );
  }
} 