# Phase 5: Verification

## Requirements
Confirm the entire project is in a valid, runnable state: zero analyzer errors, clean codegen output, app launches without crashing, and GoRouter successfully navigates between at least two routes.

## Steps
1. Run `flutter analyze` from the project root and fix every reported error — warnings on unused stub parameters are acceptable but errors are not.
2. Run `dart run build_runner build --delete-conflicting-outputs` to generate all freezed/json_serializable files — confirm it exits cleanly with no `Unresolvable conflict` messages.
3. Launch the app with `flutter run` and verify it reaches the SplashPage without a red error screen.
4. Manually exercise the auth flow: confirm SplashPage redirects to LoginPage (unauthenticated state), and that entering any non-empty email/password triggers `AuthLoading` then `AuthAuthenticated` and navigates to `ProductListPage`.
5. Verify GoRouter breadcrumb: from ProductListPage, tap any product and confirm ProductDetailPage renders with the correct product ID in the AppBar — proving path parameters flow correctly.
6. Confirm the DI container is healthy: add a temporary `debugPrint(sl<AuthBloc>().toString())` in main.dart, run the app, and verify no `StateError: Object/factory not found` is thrown — then remove the debug line.

## Success Criteria
- `flutter analyze` exits with 0 errors (run from project root, not just `lib/`)
- `dart run build_runner build` exits with code 0 (no codegen errors)
- App launches to SplashPage on cold start — no red error screen
- Tapping a product in ProductListPage navigates to ProductDetailPage — no crash
- `sl<AuthBloc>()` returns a valid instance — no get_it StateError in logs
- `flutter test` passes (even with zero test files — confirms test harness is intact)

## Risks
- `flutter analyze` may flag `prefer_const_constructors` warnings on stub pages — these are warnings, not errors; the lint rule is not enforced at error level in the provided `analysis_options.yaml`
- If `build_runner` reports `Skipping` messages for files with no codegen annotations, that is normal — it only generates output for files with `@freezed`, `@JsonSerializable`, etc.
- GoRouter `debugLogDiagnostics: true` set in Phase 3 will print every navigation event to the console — this is intentional during verification; set to `false` before production builds

---

## Verification Commands (run in order)

```powershell
# 1. Static analysis
flutter analyze

# 2. Codegen (only needed if freezed annotations are present)
dart run build_runner build --delete-conflicting-outputs

# 3. Run on connected device or emulator
flutter run

# 4. Run tests (baseline — no tests yet, but must not error)
flutter test
```

## Expected `flutter analyze` Output (clean state)

```
Analyzing flutter_ecommerce...
No issues found! (ran in X.Xs)
```

If you see errors like the ones below, apply the fix shown:

| Error | Fix |
|---|---|
| `Target of URI doesn't exist: 'package:flutter_ecommerce/features/auth/...'` | File was not created — create the missing file |
| `The method 'read' isn't defined for the class 'BuildContext'` | Missing `import 'package:flutter_bloc/flutter_bloc.dart'` |
| `A value of type 'X' can't be assigned to a variable of type 'Y'` | Type mismatch in repository impl — check that concrete class implements abstract interface |
| `The argument type 'AuthBloc' can't be assigned to parameter type 'BlocBase<AuthState>'` | Import mismatch — confirm BlocProvider generic matches the exact BLoC class |
| `sdk constraint "^3.11.5" is not valid` | Phase 1 was not completed — fix pubspec.yaml first |
| `Undefined class 'ResultFailure'` | Used wrong class name — check `result.dart` exports `ResultFailure` not `Failure` |

## Common `dart run build_runner` Errors

| Error | Fix |
|---|---|
| `Could not find a file named 'part_file.freezed.dart'` | Add `part 'filename.freezed.dart';` directive to the annotated file |
| `Too many positional arguments` | Freezed generated factory signature changed — run `build_runner clean` then rebuild |
| `Unresolvable conflict on output` | Use `--delete-conflicting-outputs` flag (already included in the command above) |

## Manual Navigation Test Script

After the app is running, perform these actions in order and confirm no crash at each step:

1. **Cold start** — App shows SplashPage with loading spinner
2. **Auto-redirect** — After ~1 second, SplashPage redirects to LoginPage (unauthenticated)
3. **Login** — Enter any email + password, tap "Sign In" — spinner appears then ProductListPage loads with 2 mock products
4. **Product tap** — Tap "Wireless Headphones" — ProductDetailPage appears with the product name
5. **Back navigation** — Tap back arrow — returns to ProductListPage without crash
6. **GoNamed test** — From LoginPage, tap "Don't have an account?" — navigates to RegisterPage via named route `AppRoutes.register`

## Final Folder Structure Verification

After all phases are complete, run this PowerShell command to confirm the folder tree matches the spec:

```powershell
Get-ChildItem -Path lib -Recurse -Directory | Select-Object FullName
```

Confirm these directories exist (minimum required by spec):

```
lib\app\router
lib\app\theme
lib\core\constants
lib\core\di
lib\core\errors
lib\core\network
lib\core\storage
lib\core\utils\extensions
lib\core\widgets
lib\features\auth\data\datasources
lib\features\auth\data\models
lib\features\auth\data\repositories
lib\features\auth\domain\entities
lib\features\auth\domain\repositories
lib\features\auth\domain\usecases
lib\features\auth\presentation\bloc
lib\features\auth\presentation\pages
lib\features\auth\presentation\widgets
lib\features\product\data\datasources
lib\features\product\data\models
lib\features\product\data\repositories
lib\features\product\domain\entities
lib\features\product\domain\repositories
lib\features\product\domain\usecases
lib\features\product\presentation\bloc
lib\features\product\presentation\pages
lib\features\cart\data\repositories
lib\features\cart\domain\entities
lib\features\cart\domain\repositories
lib\features\cart\presentation\cubit
lib\features\cart\presentation\pages
lib\features\checkout\presentation\pages
lib\features\order\presentation\pages
lib\features\profile\presentation\pages
```

## Checklist

- [ ] `flutter analyze` — 0 errors
- [ ] `dart run build_runner build --delete-conflicting-outputs` — exits cleanly
- [ ] `flutter test` — exits cleanly (0 tests is fine)
- [ ] `flutter run` — app launches, SplashPage visible
- [ ] SplashPage redirects to LoginPage (unauthenticated flow confirmed)
- [ ] Login with any credentials navigates to ProductListPage
- [ ] ProductDetailPage opens with product name displayed
- [ ] Named back-navigation (Register -> Login) works via `goNamed`
- [ ] No `StateError` in console from get_it
- [ ] All 6 feature directory trees verified with PowerShell command above
- [ ] Remove any debug `debugPrint` statements added during verification
- [ ] Set `GoRouter(debugLogDiagnostics: false)` if preparing for a demo or review
