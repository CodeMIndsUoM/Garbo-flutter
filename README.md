# garbo_swms

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


lib/
├── main.dart                 # App entry point & dependency injection setup [cite: 38]
├── app.dart                  # Role-based routing logic (Admin, Staff, Citizen) 
│
├── core/                     # Cross-cutting concerns
│   ├── constants/            # API endpoints & asset paths [cite: 30, 216]
│   ├── theme/                # Global styles & multi-lingual configs [cite: 32, 53]
│   ├── utils/                # Formatters & Permission handlers (GPS/Camera) [cite: 128]
│   └── errors/               # Custom Failure objects for API/GPS errors
│
├── data/                     # INFRASTRUCTURE LAYER (External Communication)
│   ├── sources/              # Remote & Local Data Providers
│   │   ├── api_service.dart  # REST client for Spring Boot (Dio/Http) [cite: 141, 143]
│   │   ├── storage_service.dart# AWS S3 / GCS Upload logic for photos [cite: 173, 176]
│   │   ├── location_service.dart# Streams from Phone GPS hardware [cite: 28, 227]
│   │   └── local_db.dart     # SQLite/Hive for offline data caching [cite: 130]
│   ├── models/               # DTOs (Data Transfer Objects) [cite: 45]
│   │   ├── bin_model.dart    # Maps JSON from backend to Dart objects
│   │   └── route_model.dart  # Maps Google Maps/OR-Tools polyline data [cite: 161, 167]
│   └── repositories/         # Implementation of domain repository interfaces
│
├── domain/                   # LOGIC LAYER (Pure Dart)
│   ├── entities/             # Core business objects (Bin, Task, Feedback) [cite: 43]
│   ├── repositories/         # Abstract contracts (Interfaces)
│   └── usecases/             # Specific business actions
│       ├── update_bin_status.dart # Logic for "Fill Level + Photo + GPS" [cite: 49, 188]
│       ├── get_optimized_route.dart # Logic for "Dijkstra/A* pathing" [cite: 30, 190]
│       └── submit_feedback.dart # Citizen reporting logic [cite: 220]
│
├── presentation/             # UI LAYER (Organized by User Roles) [cite: 218]
│   ├── auth/                 # Screens for Authentication
│   │   ├── pages/            # LoginPage, RegisterPage, ForgotPasswordPage
│   │   └── state/            # Auth state management logic
│   ├── field_staff/          # Screens for Bin Monitoring [cite: 218]
│   │   ├── pages/            # BinCapturePage, StaffDashboard
│   │   └── state/            # BLoC/Riverpod logic for staff tasks
│   ├── collection_team/      # Screens for Route Execution [cite: 219]
│   │   ├── pages/            # MapNavigationPage, TaskCompletePage
│   │   ├── state/            # Map/GPS state management logic
│   │   └── widgets/          # Collection-team-specific widgets (RouteCard, BinItem, etc.)
│   ├── citizen/              # Screens for Feedback Portal [cite: 220]
│   │   ├── pages/            # ComplaintFormPage, StatusTrackerPage
│   │   └── state/            # Feedback submission state
│   └── widgets/              # Reusable UI (Custom Buttons, Cards, Loaders)
