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

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
