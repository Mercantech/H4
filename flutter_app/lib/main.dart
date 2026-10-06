import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'features/weather/bloc/weather_bloc.dart';
import 'features/weather/view/weather_page.dart';
import 'features/infographic/view/infographic_page.dart';
import 'core/theme/theme.dart';

/// Main entry point
/// 
/// Initialiserer app dependencies og configuration før app starter.
/// 
/// Setup steps:
/// 1. Initialisér app configuration (environment)
/// 2. Setup dependency injection
/// 3. Start app
void main() async {
  // Sikr at Flutter bindings er initialiseret
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialisér App Configuration
  // Docker/prod: flutter build web --dart-define=APP_ENV=production
  // Lokalt default: development → http://localhost:5000/api
  const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');
  final environment = switch (appEnv) {
    'production' => Environment.production,
    'staging' => Environment.staging,
    _ => Environment.development,
  };
  await AppConfig.initialize(environment);

  // Log hvilket environment vi kører i
  debugPrint('🚀 Starting app in ${AppConfig.instance.environment.name} mode');
  debugPrint('📡 API Base URL: ${AppConfig.instance.apiBaseUrl}');

  // 2. Setup Dependency Injection
  await setupDependencyInjection();
  debugPrint('✅ Dependency Injection setup complete');

  // 3. Start App
  runApp(const MyApp());
}

/// Tip: Skift environment nemt
/// 
/// For at skifte mellem localhost og deployed API, ændre bare Environment i main():
/// - Development (localhost): Environment.development
/// - Production (deployed): Environment.production
/// - Staging (hvis I har det): Environment.staging

/// Root app widget
/// 
/// Setup BLoC providers og MaterialApp.
/// BLoCs injiceres via DI container (getIt).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Weather BLoC - injected via DI
        // Factory registration giver os ny instance hver gang
        BlocProvider(
          create: (context) => getIt<WeatherBloc>(),
        ),
        
        // TODO: Tilføj flere BLoCs her efterhånden:
        // BlocProvider(
        //   create: (context) => getIt<LoginBloc>(),
        // ),
      ],
      child: MaterialApp(
        title: 'H4 Vejr App',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    WeatherPage(),
    InfographicPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Vejr',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'BLoC',
          ),
        ],
      ),
    );
  }
}


