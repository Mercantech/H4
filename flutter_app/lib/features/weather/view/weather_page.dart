import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/weather_view_model.dart';
import '../widgets/weather_list.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    // Hent vejrdata når siden indlæses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().loadWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vejrforudsigelse'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WeatherViewModel>().refresh();
            },
            tooltip: 'Opdater',
          ),
        ],
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.state) {
            case WeatherState.initial:
              return const Center(
                child: Text(
                  'Tryk på opdater for at hente vejrdata',
                  style: TextStyle(fontSize: 16),
                ),
              );
              
            case WeatherState.loading:
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Henter vejrdata...'),
                  ],
                ),
              );
              
            case WeatherState.loaded:
              return WeatherList(
                forecasts: viewModel.weatherData,
                chartData: viewModel.chartData,
              );
              
            case WeatherState.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fejl ved hentning af vejrdata',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.refresh();
                      },
                      child: const Text('Prøv igen'),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
} 