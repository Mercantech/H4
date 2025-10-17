# BLoC Pattern Dokumentation

## 📚 Indholdsfortegnelse
- [Hvad er BLoC?](#hvad-er-bloc)
- [Hvorfor BLoC?](#hvorfor-bloc)
- [Kernekoncepter](#kernekoncepter)
- [Arkitektur](#arkitektur)
- [Implementation i Vejr App](#implementation-i-vejr-app)
- [BLoC vs MVVM/Provider](#bloc-vs-mvvmprovider)
- [Best Practices](#best-practices)
- [Testning](#testning)

---

## Hvad er BLoC?

**BLoC** står for **Business Logic Component** og er et arkitekturmønster designet af Google til Flutter/Dart apps. BLoC bygger på **streams** og **reactive programming** for at adskille forretningslogik fra UI.

### Hovedidé
```
UI → Events → BLoC → States → UI
```

- **UI** sender **Events** til BLoC
- **BLoC** behandler events og emitter **States**
- **UI** reagerer på state ændringer

---

## Hvorfor BLoC?

### ✅ Fordele

1. **Klar Separation**
   - Komplet adskillelse mellem UI og business logic
   - UI kender kun til states, ikke hvordan de genereres

2. **Testbarhed**
   - BLoC kan testes isoleret uden UI
   - Nemt at mocke dependencies
   - Forudsigelig state management

3. **Genanvendelighed**
   - Samme BLoC kan bruges på tværs af platforms (iOS, Android, Web)
   - Logikken er uafhængig af UI framework

4. **Reaktiv Programmering**
   - Bygger på streams (Dart's async værktøj)
   - Automatisk UI opdatering ved state ændringer

5. **Skalerbarhed**
   - Perfekt til store, komplekse apps
   - Struktureret og forudsigelig dataflow

### ⚠️ Ulemper

1. **Indlæringskurve**
   - Kræver forståelse af streams, async/await
   - Mere boilerplate kode end Provider

2. **Overkill for Simple Apps**
   - Kan være for tungt til små apps med få states

---

## Kernekoncepter

### 1️⃣ Events (Input)

Events repræsenterer **hvad der sker** i appen - brugerhandlinger eller systemhændelser.

```dart
// Base class
abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
  
  @override
  List<Object?> get props => [];
}

// Konkrete events
class LoadWeatherData extends WeatherEvent {
  const LoadWeatherData();
}

class RefreshWeatherData extends WeatherEvent {
  const RefreshWeatherData();
}
```

**Karakteristika:**
- Immutable (const)
- Udvider `Equatable` for sammenligning
- Beskriver en intention (LoadData, UpdateUser, DeleteItem)

---

### 2️⃣ States (Output)

States repræsenterer **tilstanden** af UI på et givent tidspunkt.

```dart
// Base class
abstract class WeatherState extends Equatable {
  const WeatherState();
  
  @override
  List<Object?> get props => [];
}

// Konkrete states
class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

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

class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

**Karakteristika:**
- Immutable
- Indeholder data UI har brug for
- Udvider `Equatable` så BLoC ved hvornår der er ændringer

---

### 3️⃣ BLoC (Processor)

BLoC modtager events, udfører business logic og emitter states.

```dart
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _weatherService;

  WeatherBloc({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService(),
        super(const WeatherInitial()) {
    
    // Registrer event handlers
    on<LoadWeatherData>(_onLoadWeatherData);
    on<RefreshWeatherData>(_onRefreshWeatherData);
  }

  Future<void> _onLoadWeatherData(
    LoadWeatherData event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    try {
      final weatherData = await _weatherService.getWeatherForecast();
      final chartData = ChartData.fromWeatherData(weatherData);

      emit(WeatherLoaded(
        weatherData: weatherData,
        chartData: chartData,
      ));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onRefreshWeatherData(
    RefreshWeatherData event,
    Emitter<WeatherState> emit,
  ) async {
    await _onLoadWeatherData(const LoadWeatherData(), emit);
  }
}
```

**Vigtige punkter:**
- Udvider `Bloc<Event, State>`
- Initialiserer med en start state (super())
- Registrerer event handlers med `on<Event>(handler)`
- Event handlers emitter nye states via `emit()`

---

## Arkitektur

### Lag-struktur

```
┌─────────────────────────────────────┐
│           UI Layer                  │
│  (Widgets, Pages, BlocBuilder)      │
└─────────────┬───────────────────────┘
              │ Events ↓
              │ States ↑
┌─────────────▼───────────────────────┐
│        BLoC Layer                   │
│  (Business Logic Components)        │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│      Repository Layer               │
│  (Data abstraction)                 │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│      Data Layer                     │
│  (API, Database, Cache)             │
└─────────────────────────────────────┘
```

### Fil struktur

```
lib/
├── features/
│   └── weather/
│       ├── bloc/
│       │   ├── weather_bloc.dart      # BLoC logic
│       │   ├── weather_event.dart     # Events
│       │   └── weather_state.dart     # States
│       ├── model/
│       │   └── chart_data.dart        # Domain models
│       ├── view/
│       │   └── weather_page.dart      # UI
│       └── widgets/
│           ├── weather_card.dart
│           ├── weather_chart.dart
│           └── weather_list.dart
├── data/
│   ├── models/                        # Data models
│   │   └── weather_forecast.dart
│   └── services/                      # Data sources
│       └── weather_service.dart
└── main.dart
```

---

## Implementation i Vejr App

### 1. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter_bloc: ^8.1.3    # Core BLoC
  equatable: ^2.0.5       # Value equality
```

### 2. Setup i main.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WeatherBloc(),
        ),
        // Add flere BLoCs her
      ],
      child: MaterialApp(
        home: MainNavigation(),
      ),
    );
  }
}
```

### 3. Brug i UI

```dart
class WeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Dispatcher event
              context.read<WeatherBloc>()
                  .add(const RefreshWeatherData());
            },
          ),
        ],
      ),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          // Pattern matching på state
          if (state is WeatherInitial) {
            // Hent data automatisk
            context.read<WeatherBloc>()
                .add(const LoadWeatherData());
            return CircularProgressIndicator();
          } 
          
          if (state is WeatherLoading) {
            return CircularProgressIndicator();
          }
          
          if (state is WeatherLoaded) {
            return WeatherList(
              forecasts: state.weatherData,
              chartData: state.chartData,
            );
          }
          
          if (state is WeatherError) {
            return ErrorWidget(state.message);
          }
          
          return Text('Ukendt tilstand');
        },
      ),
    );
  }
}
```

---

## BLoC vs MVVM/Provider

| Aspekt | BLoC | MVVM/Provider |
|--------|------|---------------|
| **State Management** | Streams & Events | ChangeNotifier |
| **Kompleksitet** | Højere indlæringskurve | Lettere at lære |
| **Boilerplate** | Mere kode | Mindre kode |
| **Testbarhed** | Meget høj | Medium |
| **Reaktivitet** | Indbygget med streams | Manuel notify |
| **Separation** | Komplet adskillelse | God adskillelse |
| **Performance** | Optimeret med Equatable | God |
| **Best for** | Store/komplekse apps | Små/mellemstore apps |

### Hvornår bruge hvad?

**Brug BLoC når:**
- ✅ App har kompleks state management
- ✅ Du vil have maksimal testbarhed
- ✅ State flow er kritisk og skal være forudsigelig
- ✅ Team har erfaring med reactive programming

**Brug Provider/MVVM når:**
- ✅ App er relativt simpel
- ✅ Hurtig udvikling er prioritet
- ✅ Team er nyt til Flutter
- ✅ Mindre boilerplate ønskes

---

## Best Practices

### 1. ✅ Navngivning

```dart
// Events: Handling i imperativ form
class LoadWeatherData extends WeatherEvent {}
class UpdateUser extends UserEvent {}
class DeleteItem extends ItemEvent {}

// States: Beskrivende tilstand
class WeatherLoaded extends WeatherState {}
class UserUpdated extends UserState {}
class ItemDeleted extends ItemState {}
```

### 2. ✅ Single Responsibility

Hver BLoC skal kun håndtere ÉN feature/domæne:

```dart
// ✅ Godt
WeatherBloc   // Kun vejr-relateret
UserBloc      // Kun bruger-relateret
AuthBloc      // Kun authentication

// ❌ Dårligt
AppBloc       // Alt i én
```

### 3. ✅ Immutability

States og events skal ALTID være immutable:

```dart
// ✅ Godt
class WeatherLoaded extends WeatherState {
  final List<Weather> data;  // final
  const WeatherLoaded(this.data);  // const constructor
}

// ❌ Dårligt
class WeatherLoaded extends WeatherState {
  List<Weather> data;  // Mutable
  WeatherLoaded(this.data);
}
```

### 4. ✅ Error Handling

Håndter altid fejl i BLoC:

```dart
Future<void> _onLoadData(
  LoadData event,
  Emitter<State> emit,
) async {
  emit(const Loading());
  
  try {
    final data = await repository.getData();
    emit(Loaded(data));
  } on NetworkException catch (e) {
    emit(Error('Netværksfejl: ${e.message}'));
  } catch (e) {
    emit(Error('Ukendt fejl: $e'));
  }
}
```

### 5. ✅ Brug BlocProvider korrekt

```dart
// ✅ Godt: Provider på app-niveau hvis delt
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => WeatherBloc()),
  ],
  child: MaterialApp(...),
)

// ✅ Godt: Provider på page-niveau hvis lokal
class WeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherBloc()..add(LoadData()),
      child: WeatherView(),
    );
  }
}
```

---

## Testning

BLoC gør testing meget nemt fordi logikken er isoleret.

### Unit Test Eksempel

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

void main() {
  group('WeatherBloc', () {
    late WeatherBloc weatherBloc;
    late MockWeatherService mockService;

    setUp(() {
      mockService = MockWeatherService();
      weatherBloc = WeatherBloc(weatherService: mockService);
    });

    tearDown(() {
      weatherBloc.close();
    });

    test('initial state is WeatherInitial', () {
      expect(weatherBloc.state, equals(const WeatherInitial()));
    });

    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherLoading, WeatherLoaded] when LoadWeatherData succeeds',
      build: () {
        when(() => mockService.getWeatherForecast())
            .thenAnswer((_) async => [mockWeatherData]);
        return weatherBloc;
      },
      act: (bloc) => bloc.add(const LoadWeatherData()),
      expect: () => [
        const WeatherLoading(),
        isA<WeatherLoaded>(),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherLoading, WeatherError] when LoadWeatherData fails',
      build: () {
        when(() => mockService.getWeatherForecast())
            .thenThrow(Exception('Network error'));
        return weatherBloc;
      },
      act: (bloc) => bloc.add(const LoadWeatherData()),
      expect: () => [
        const WeatherLoading(),
        isA<WeatherError>(),
      ],
    );
  });
}
```

### Dependencies for testing

```yaml
dev_dependencies:
  bloc_test: ^9.1.4
  mocktail: ^1.0.0
```

---

## Konklusion

BLoC er et kraftfuldt arkitekturmønster der giver:
- 🎯 Klar separation mellem UI og logic
- 🧪 Ekstremt testbar kode
- 🔄 Reaktiv og forudsigelig state management
- 📦 Genanvendelig logic på tværs af platforms

Det kræver mere setup end Provider/MVVM, men giver bedre struktur til komplekse apps.

### Næste skridt

1. ✅ Implementeret Weather feature med BLoC
2. 📝 Dokumenteret BLoC pattern
3. 🎨 Opdateret infographic til BLoC
4. 🚀 Klar til at bygge flere features!

---

## Ressourcer

- [Official BLoC Library](https://bloclibrary.dev/)
- [Flutter BLoC Package](https://pub.dev/packages/flutter_bloc)
- [BLoC Architecture Course](https://www.youtube.com/watch?v=THCkkQ-V1-8)
- [Equatable Package](https://pub.dev/packages/equatable)

