# flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Flutter Arkitektur - BLoC Pattern

BLoC (Business Logic Component) er et arkitekturmønster der adskiller forretningslogik fra UI ved hjælp af streams og events. Mønsteret sikrer en klar separation mellem præsentationslag og business logic, hvilket gør koden meget testbar og genanvendelig.

### Nøglekoncepter

- **Events**: Input til BLoC - repræsenterer brugerhandlinger eller systemhændelser
- **BLoC**: Behandler events og emitter states - indeholder al forretningslogik
- **States**: Output fra BLoC - repræsenterer UI-tilstanden
- **View**: UI-lag der lytter til states og dispatcher events

```
UI → Events → BLoC → States → UI
```

📖 **Se [BLOC_DOCUMENTATION.md](./BLOC_DOCUMENTATION.md) for omfattende dokumentation**

## Projektstruktur (BLoC)

Projektet følger BLoC-arkitekturen og har følgende mappestruktur under `lib/`:

```
lib/
  core/           # Grundlæggende konstanter, temaer og hjælpefunktioner
    constants/    # Applikationskonstanter som farver, strenge, API-endepunkter
    theme/        # Applikationens design-tema (farver, typografi, spacing)
    utils/        # Hjælpefunktioner og utility-klasser
  data/           # Data-adgangslag (modeller og services)
    models/       # Data-modeller (API responses, domain objekter)
                  # - API response modeller (JSON til Dart objekter)
                  # - Database modeller (lokal database)
                  # - Domain modeller (business logic objekter)
    services/     # Services der håndterer data-operationer
                  # - API services (HTTP requests til backend)
                  # - Database services (CRUD operationer)
                  # - Authentication services
  features/       # Features opdelt efter domæne (feature-first approach)
    weather/      # Vejr feature
      bloc/       # 🟣 BLoC komponenter for weather
                  # - weather_bloc.dart (business logic)
                  # - weather_event.dart (input events)
                  # - weather_state.dart (output states)
      model/      # Domain modeller for weather
      view/       # UI-komponenter (Pages/Screens)
      widgets/    # Genanvendelige widgets for weather
    infographic/  # BLoC infografik feature
      view/       # Infografik side med BLoC forklaring
  routing/        # Navigationslogik og ruter
  shared/         # Delte components på tværs af features
    extensions/   # Dart extensions
    widgets/      # Delte UI-komponenter
  main.dart       # Applikationens entrypoint
```

### BLoC Fordele

✅ **Klar separation** mellem UI og business logic  
✅ **Meget testbar** - BLoC kan testes isoleret  
✅ **Genanvendelig** - samme BLoC på tværs af platforms  
✅ **Reaktiv** - automatisk UI opdatering ved state ændringer  
✅ **Forudsigelig** - veldefineret dataflow