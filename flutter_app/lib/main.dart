import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/weather/bloc/weather_bloc.dart';
import 'features/weather/view/weather_page.dart';
import 'features/infographic/view/infographic_page.dart';
import 'core/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Weather BLoC - håndterer vejr-relateret state
        BlocProvider(
          create: (context) => WeatherBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Vejr App',
        theme: appTheme,
        debugShowCheckedModeBanner: false, // Fjerner DEBUG banner
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


