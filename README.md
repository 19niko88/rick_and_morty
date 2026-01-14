# Rick and Morty App

A Flutter application that displays characters from the Rick and Morty universe using the [Rick and Morty API](https://rickandmortyapi.com/). The app features character browsing, filtering, favorites management, and theme customization.

## Features

- **Character List**: Browse all characters with infinite scroll pagination
- **Advanced Filtering**: Filter characters by name, status, species, type, and gender
- **Character Details**: View detailed information about each character
- **Favorites**: Save and manage your favorite characters locally
- **Dark Theme**: Switch between light, dark, and system themes with persistent preference
- **Offline Support**: Cached data allows viewing previously loaded characters without internet

## Architecture

The app follows Clean Architecture principles with BLoC pattern for state management:

- **Presentation Layer**: UI components and BLoC state management
- **Domain Layer**: Business logic and entities
- **Data Layer**: API integration and local storage

### Key Technologies

- **State Management**: BLoC + Freezed
- **Dependency Injection**: GetIt + Injectable
- **Navigation**: AutoRoute
- **Networking**: Dio + Retrofit
- **Local Storage**: Hive
- **Code Generation**: build_runner, freezed, json_serializable

## Requirements

- **Flutter SDK**: 3.10.3 or higher
- **Dart SDK**: Included with Flutter
- **iOS**: Xcode 14.0+ (for iOS development)
- **Android**: Android Studio with SDK 21+ (for Android development)

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd rick_and_morty
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Install iOS pods (iOS only)

```bash
cd ios
pod install
cd ..
```

### 4. Generate code

Run code generation for Freezed, Injectable, AutoRoute, and Retrofit:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Running the App

### Development Mode

```bash
flutter run
```

### Release Mode

```bash
flutter run --release
```

### Specific Platform

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## Project Structure

```
lib/
├── config/              # App configuration (DI, routing, constants)
├── data/                # Data layer (repositories, data sources, API)
├── domain/              # Domain layer (models, enums)
├── presentation/        # Presentation layer (screens, widgets, BLoCs)
└── utils/               # Utilities and helpers
```

## Key Dependencies

### Production

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | ^9.1.1 | State management |
| freezed | ^3.2.3 | Code generation for models |
| get_it | ^9.2.0 | Dependency injection |
| injectable | ^2.7.1+4 | DI code generation |
| auto_route | ^11.1.0 | Navigation |
| dio | ^5.9.0 | HTTP client |
| retrofit | ^4.9.2 | Type-safe API client |
| hive | ^2.2.3 | Local database |
| cached_network_image | ^3.4.1 | Image caching |
| flutter_screenutil | ^5.9.3 | Responsive UI |

### Development

| Package | Version | Purpose |
|---------|---------|---------|
| build_runner | ^2.4.15 | Code generation runner |
| injectable_generator | ^2.6.2 | DI code generation |
| json_serializable | ^6.11.3 | JSON serialization |
| auto_route_generator | ^10.4.0 | Route generation |
| retrofit_generator | ^10.2.1 | API client generation |

## Code Generation

After modifying models, BLoCs, or routes, regenerate code:

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
dart run build_runner watch --delete-conflicting-outputs
```

## Features in Detail

### Theme Switching

The app supports three theme modes:
- **Light**: Light color scheme
- **Dark**: Dark color scheme
- **System**: Follows system theme preference

Theme preference is persisted locally using Hive.

### Offline Caching

- Characters are cached locally after first load
- Favorites are stored locally and available offline
- App gracefully handles network errors

### Filtering

Filter characters by multiple criteria:
- Name (text search)
- Status (Alive, Dead, Unknown)
- Species (Human, Alien, etc.)
- Gender (Male, Female, Genderless, Unknown)
- Type (custom type field)

## API Reference

This app uses the [Rick and Morty API](https://rickandmortyapi.com/documentation):
- Base URL: `https://rickandmortyapi.com/api`
- Endpoints: `/character`, `/character/{id}`

## License

This project is for educational purposes.

## Credits

- API: [Rick and Morty API](https://rickandmortyapi.com/)
- Show: Rick and Morty © Adult Swim
