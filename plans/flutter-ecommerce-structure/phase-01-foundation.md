# Phase 1: Foundation

## Requirements
Fix the invalid Dart SDK constraint that currently prevents package resolution, add all MVP packages to `pubspec.yaml`, and replace the default `main.dart` counter demo with a clean entry-point skeleton that the rest of the plan will build on.

## Steps
1. Fix the `sdk:` constraint in `pubspec.yaml` from the invalid `^3.11.5` to the valid range `">=3.3.0 <4.0.0"`, then add all runtime and dev dependencies listed below.
2. Run `flutter pub get` and confirm it exits cleanly with no resolution errors.
3. Replace `lib/main.dart` entirely with a minimal skeleton that calls `WidgetsFlutterBinding.ensureInitialized()`, a placeholder `configureDependencies()` call, and a `runApp(App())` — matching what Phases 2–3 will flesh out.

## Success Criteria
- `flutter pub get` exits with code 0 and no version conflicts
- `pubspec.yaml` no longer contains `sdk: ^3.11.5`
- `lib/main.dart` compiles (no red underlines) and contains no counter demo code
- `flutter analyze lib/main.dart` reports 0 issues

## Risks
- Version conflict between `intl` and Flutter's bundled intl: use `^0.19.0` exactly as pinned — do not upgrade to 0.20.x without checking Flutter SDK release notes
- If `flutter pub get` still fails after the SDK fix, run `flutter clean` then retry

---

## Exact File Contents

### `pubspec.yaml` — full replacement

```yaml
name: flutter_ecommerce
description: "Flutter e-commerce MVP."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # UI
  cupertino_icons: ^1.0.8
  cached_network_image: ^3.0.0

  # State management
  flutter_bloc: ^9.0.0
  bloc: ^9.0.0
  equatable: ^2.0.0

  # Navigation
  go_router: ^14.0.0

  # Networking
  dio: ^5.0.0

  # Dependency injection
  get_it: ^8.0.0

  # Storage
  shared_preferences: ^2.0.0

  # Utilities
  intl: ^0.19.0

  # Code generation runtime annotations
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code generation
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0

flutter:
  uses-material-design: true
```

### `lib/main.dart` — full replacement

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart' as di;

// App widget is defined in app/app.dart — wired in Phase 3.
// Until Phase 3 is complete, use the temporary placeholder below.
import 'package:flutter_ecommerce/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.configureDependencies();
  runApp(const App());
}
```

> **Note for the developer:** `app/app.dart` and `core/di/injection_container.dart` do not exist yet — the project will not compile until Phase 2 and Phase 3 are complete. This is expected. Create these stub files immediately after updating main.dart so the project stays in a buildable state:

### Temporary stub — `lib/core/di/injection_container.dart`

Create this file now so `main.dart` can resolve the import. It will be fully implemented in Phase 2.

```dart
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Registrations added in Phase 2 (core) and Phase 4 (features).
}
```

### Temporary stub — `lib/app/app.dart`

Create this file now so `main.dart` can resolve the import. It will be fully implemented in Phase 3.

```dart
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Replaced with MaterialApp.router in Phase 3.
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Flutter E-Commerce — bootstrapping...'),
        ),
      ),
    );
  }
}
```

## Checklist

- [ ] Open `pubspec.yaml` and replace the entire file with the content above
- [ ] Verify line 8 reads exactly: `sdk: ">=3.3.0 <4.0.0"` (quoted, with `>=` and `<`)
- [ ] Run `flutter pub get` in the project root — confirm exit code 0
- [ ] Create `lib/core/di/injection_container.dart` with the stub above
- [ ] Create the `lib/app/` directory and add `lib/app/app.dart` with the stub above
- [ ] Replace `lib/main.dart` entirely with the content above
- [ ] Run `flutter analyze lib/main.dart lib/app/app.dart lib/core/di/injection_container.dart` — confirm 0 issues
