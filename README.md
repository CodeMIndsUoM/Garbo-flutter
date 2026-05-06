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

### Third-Party Completion Photo Upload

Photo upload is handled by backend multipart API. Flutter does not require Cloudinary Dart defines.

Team workflow:

1. Start backend with Cloudinary environment variables.
2. Run Flutter app normally.
3. Complete collection flow will send photo file to backend, and backend uploads to Cloudinary.

## Test Login Credentials

These mobile test accounts are intended for shared team login testing.

Important:
- Start the backend first so the seed data is created.
- `ROLE_SUPERADMIN` is only for the web dashboard, not the mobile app.

| Mobile Role | Email | Password | Mobile Destination |
|-------|--------|--------|--------|
| Citizen | `citizen.one@garbo.com` | `Citizen123` | Citizen home |
| Collection Team | `collector.test@garbo.com` | `Collector123` | Collection team dashboard |
| Field Staff | `sasindu@gmail.com` | `Sj1234` | Field staff dashboard |
| Third-Party Collector | `thirdparty.one@garbo.com` | `ThirdParty123` | Third-party collector home |

Additional seeded demo accounts:

| Mobile Role | Email | Password | Mobile Destination |
|-------|--------|--------|--------|
| Citizen | `citizen.two@garbo.com` | `Citizen123` | Citizen home |
| Citizen | `citizen.three@garbo.com` | `Citizen123` | Citizen home |
| Third-Party Collector | `thirdparty.two@garbo.com` | `ThirdParty123` | Third-party collector home |
| Third-Party Collector | `thirdparty.three@garbo.com` | `ThirdParty123` | Third-party collector home |

### Create Seed Users

Run the backend once to create these accounts automatically:

```bash
cd ../Garbo_backend
./run-local.sh
```

Note: `run-local.sh` loads `.env` first, so Cloudinary-backed upload endpoints work correctly.

## Project Structure

```
lib/
├── main.dart                         # App entry point
├── app.dart                          # Root app widget
├── core/                             # Shared app-level config and styling
│   ├── constants/                    # API base URL and shared constants
│   ├── errors/                       # Shared error placeholders / future expansion
│   ├── router/                       # Central app routing
│   ├── theme/                        # Colors and typography
│   └── utils/                        # Shared utility placeholders / future expansion
├── data/                             # API-facing models and services
│   ├── models/                       # Request/offer/dashboard/websocket models
│   ├── repositories/                 # Reserved for repository implementations
│   └── sources/                      # REST and websocket services
├── domain/                           # Reserved clean-architecture domain layer
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/                     # UI grouped by role and feature
    ├── auth/                         # Login/register/forgot-password flow
    │   ├── pages/
    │   └── state/
    ├── citizen/                      # Citizen request and reporting experience
    │   ├── pages/
    │   ├── state/
    │   └── widgets/
    ├── collection_team/              # Bin collector route and job screens
    │   ├── pages/
    │   ├── state/
    │   └── widgets/
    ├── field_staff/                  # Field mentor dashboard, bins, and profile
    │   ├── bins/
    │   ├── dashboard/
    │   ├── profile/
    │   ├── shared/
    │   └── state/
    ├── providers/                    # Cross-screen providers and app state
    ├── third_party_collector/        # Feed, jobs, profile, and completion flow
    │   ├── pages/
    │   └── widgets/
    └── widgets/                      # Shared presentation widgets
```

## Architecture

The codebase uses a mostly role-based presentation structure with lightweight layered separation:

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| **Presentation** | `presentation/` | Role-specific pages, widgets, and providers |
| **Data** | `data/` | API services, websocket services, and response models |
| **Core** | `core/` | Routing, constants, and theme |
| **Domain** | `domain/` | Reserved for domain abstractions and future use cases |

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
