# Georgia Travel Guide — Mobile (Flutter)

Flutter client for the tourist guide app. Talks to the API Gateway over REST,
using **Riverpod** for state and a **Clean-Architecture-style** feature layout
(`data` → repositories/models, `presentation` → providers/screens).

## Prerequisites

- Flutter SDK 3.19+ (`flutter --version`)
- The backend running (`docker compose up` in the backend repo) so the gateway
  is reachable on `http://localhost:8080`.

## First-time setup

This folder contains only `lib/` and `pubspec.yaml`. Generate the platform
folders (android/ios/etc.) once, on top of these files:

```bash
flutter create .          # creates android/, ios/, etc. without touching lib/
flutter pub get
```

## Run

```bash
# Android emulator (10.0.2.2 = your host's localhost)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080

# Physical device: use your machine's LAN IP, e.g.
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080
```

## Important: allow cleartext HTTP for local dev

The dev backend uses plain `http://`, which Android blocks by default. After
`flutter create .`, open `android/app/src/main/AndroidManifest.xml` and add
`android:usesCleartextTraffic="true"` to the `<application>` tag:

```xml
<application
    android:label="georgia_travel_guide"
    android:usesCleartextTraffic="true"
    ...>
```

(For production over HTTPS this is not needed — remove it.)

## What's implemented

- Registration / login with JWT stored in secure storage; automatic token
  refresh on 401 (see `core/network/dio_client.dart`).
- Cities list with search and region filter, pull-to-refresh.
- City detail with tabs: attractions, restaurants, hotels, routes.
- Route detail screen.
- Favorites (add/remove a city, view the list).
- Profile with logout.
- Map screen (OpenStreetMap via `flutter_map`, no API key) showing the city and
  its attractions.

## Structure

```
lib/
  main.dart
  core/
    config/       API base URL (from --dart-define)
    network/      Dio client + auth interceptor, error mapping
    storage/      secure token storage
    router/       go_router + auth redirect
    theme/  widgets/
  features/
    auth/ cities/ places/ routes/ favorites/ profile/ home/ map/
      data/          models + repository (talks to REST)
      presentation/  Riverpod providers + screens
```

## Notes

- State management is manual Riverpod (Notifier / AsyncNotifier / FutureProvider),
  so **no build_runner step is required**. JSON parsing is hand-written in each model.
- The map uses OpenStreetMap tiles. If you prefer Google Maps, swap `flutter_map`
  for `google_maps_flutter` (needs an API key and platform config).
- Endpoints and payloads match the backend gateway (`/api/...`). If you change the
  backend contract, update the matching repository in `features/<x>/data/`.
