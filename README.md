# Garbo SWMS

Smart Waste Management System — A Flutter mobile application for managing urban waste collection across multiple user roles.

## Getting Started

### Prerequisites

- Flutter SDK (3.x or later)
- Dart SDK
- Android Studio / Xcode for emulator

### Run the App

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point & dependency injection setup
├── app.dart                     # Role-based routing logic (Admin, Staff, Citizen)
│
├── core/                        # Cross-cutting concerns
│   ├── constants/               # API endpoints & asset paths
│   ├── theme/                   # Global styles & color palette
│   ├── router/                  # App routing configuration
│   ├── utils/                   # Formatters & permission handlers (GPS/Camera)
│   └── errors/                  # Custom failure objects for API/GPS errors
│
├── data/                        # INFRASTRUCTURE LAYER (External Communication)
│   ├── sources/                 # Remote & local data providers
│   │   ├── api_service.dart     # REST client for Spring Boot (Dio/Http)
│   │   ├── storage_service.dart # Cloud storage upload logic for photos
│   │   ├── location_service.dart# GPS hardware streams
│   │   └── local_db.dart        # SQLite/Hive for offline data caching
│   ├── models/                  # DTOs (Data Transfer Objects)
│   │   ├── bin_model.dart       # Maps JSON from backend to Dart objects
│   │   └── route_model.dart     # Maps polyline/route data
│   └── repositories/            # Implementation of domain repository interfaces
│
├── domain/                      # LOGIC LAYER (Pure Dart)
│   ├── entities/                # Core business objects (Bin, Task, Feedback)
│   ├── repositories/            # Abstract contracts (interfaces)
│   └── usecases/                # Specific business actions
│       ├── update_bin_status.dart    # Fill level + photo + GPS logic
│       ├── get_optimized_route.dart  # Route optimization logic
│       └── submit_feedback.dart     # Citizen reporting logic
│
└── presentation/                # UI LAYER (Organized by User Roles)
    ├── auth/                    # Authentication screens
    │   └── pages/               # Login, Register, Forgot Password
    ├── field_staff/             # Bin monitoring & field operations
    │   ├── dashboard/           # Dashboard feature
    │   │   ├── dashboard_page.dart
    │   │   └── widgets/         # PerformanceGrid, BinListSection, etc.
    │   ├── bins/                # Bins management feature
    │   │   ├── bins_page.dart
    │   │   ├── models/          # BinModel & enums
    │   │   └── widgets/         # BinCard, BinFilterChips
    │   ├── shared/              # Shared across tabs
    │   │   ├── stat_header.dart
    │   │   └── field_bottom_navigation.dart
    │   └── state/               # State management logic
    ├── collection_team/         # Route execution screens
    │   ├── pages/               # MapNavigationPage, TaskCompletePage
    │   └── state/               # Map/GPS state management
    ├── citizen/                 # Feedback portal screens
    │   ├── pages/               # ComplaintFormPage, StatusTrackerPage
    │   └── state/               # Feedback submission state
    ├── third_party_collector/   # Third-party collector screens
    └── widgets/                 # Reusable UI components
```

## Architecture

The project follows **Clean Architecture** with three layers:

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| **Presentation** | `presentation/` | UI widgets, pages, state management |
| **Domain** | `domain/` | Business logic, entities, use cases |
| **Data** | `data/` | API calls, local storage, DTOs |

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
