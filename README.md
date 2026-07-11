# flutter_ecommerce

A new Flutter project.

## Backend API (Android emulator)

Default API base URL targets the host machine from the Android emulator (`http://10.0.2.2:8080`). Start the Spring Boot API with `docker-compose up` in `be-ecommerce`.

```bash
flutter run
```

Physical device or custom host:

```bash
flutter run --dart-define=BASE_URL=http://192.168.1.100:8080
```

Login uses `POST /api/auth/login` (access token + refresh cookie). Role comes from `GET /api/auth/me` (`ADMIN` → admin dashboard, `USER` → home). Session is restored on app start via saved token and refresh cookie.

## Map & directions (no API key required)

The store screen (customer) and the admin location picker use a **real map** rendered with
[`flutter_map`](https://pub.dev/packages/flutter_map) over **OpenStreetMap** tiles — **no API
key and no billing**. Directions and address search use free OpenStreetMap services:

| Feature | Service | Key? |
|---------|---------|------|
| Map tiles | OpenStreetMap (`tile.openstreetmap.org`) | none |
| Route + distance/ETA | OSRM (`router.project-osrm.org`) | none |
| Address search / geocoding | Nominatim (`nominatim.openstreetmap.org`) | none |
| "Bắt đầu" turn-by-turn | Opens the Google Maps app via URL | none |

### Run
```bash
flutter run
# iOS: run `cd ios && pod install` once after adding the map packages.
```

Location permission (for "Chỉ đường") is declared in `AndroidManifest.xml`
(`ACCESS_FINE_LOCATION`) and `Info.plist` (`NSLocationWhenInUseUsageDescription`). Internet
access is required for map tiles.

> Notes: OSRM and Nominatim are free public servers with light rate limits — fine for a
> student project / demo, not for production traffic. Nominatim requires a valid `User-Agent`
> (already set in the Places datasource). Map tiles are © OpenStreetMap contributors
> (attribution is shown on the map).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
