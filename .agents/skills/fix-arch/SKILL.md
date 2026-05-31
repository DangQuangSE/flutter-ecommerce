---
name: fix-arch
description: "Audit a feature for Clean Architecture violations and produce a prioritized fix list. Use when generated code may have broken layer rules, missing use cases, or incorrect BLoC patterns."
---

# fix-arch — Architecture Audit

Scans a feature for violations and produces an actionable fix list.

## When to use this skill

- Use this when generated code may have broken Clean Architecture layer rules.
- Use this to check for missing use cases, incorrect imports, unhandled BLoC states, or invalid DI scopes (like lazy singletons for BLoCs).

## How to use it

### Step 1 — Read the Feature

Read all files in `lib/features/{feature}/` recursively. Also read:
- `lib/core/di/injection_container.dart`
- `lib/app/router/app_router.dart`

---

### Step 2 — Run the Checklist

For each item below, mark **PASS**, **FAIL**, or **N/A**.

#### Layer Violations
- [ ] Does any `domain/` file import from `data/` or `presentation/`?
- [ ] Does any `domain/` file import `dio`, `flutter_bloc`, or `shared_preferences`?
- [ ] Does any `presentation/` file import directly from `data/` (bypassing domain)?
- [ ] Does any widget/page call `dio.get()` or `http.get()` directly?

#### Entity Rules
- [ ] Does any entity have `fromJson` or `toJson`? (belongs in model, not entity)
- [ ] Does any entity use `@JsonSerializable`?
- [ ] Does any entity import from `data/` layer?

#### Repository Rules
- [ ] Does the domain repository file contain implementation code? (must be abstract interface only)
- [ ] Does any BLoC/Cubit call a data source directly? (must go through repository → use case)
- [ ] Is there at least one use case file per feature action?

#### BLoC / Cubit Rules
- [ ] Are Event and State classes `sealed class` (not `abstract class`)?
- [ ] Does any `switch` on a sealed state use a `default:` arm?
- [ ] Is `context.read<>()` called directly inside `initState()` without `Future.microtask`?
- [ ] Does any BLoC/Cubit emit state after the stream is closed (missing mounted check)?

#### DI Rules
- [ ] Is any BLoC registered with `registerLazySingleton`? (must be `registerFactory`)
- [ ] Is `AuthBloc` registered with `registerFactory`? (must be `registerLazySingleton`)
- [ ] Are dependencies registered in correct order: DataSource → Repository → UseCase → BLoC?
- [ ] Is any feature completely missing from `injection_container.dart`?

#### Router Rules
- [ ] Does any route builder use `context.go('/hardcoded-path')` instead of `goNamed`?
- [ ] Are factory BLoCs (ProductBloc, etc.) wrapped in `BlocProvider` on the route instead of root?
- [ ] Does the router use `state.matchedLocation`? (deprecated — use `state.uri.path`)

---

### Step 3 — Report Format

Output a structured report:

```
## Architecture Audit: {feature}

### CRITICAL (breaks compile or runtime)
- [ ] {file}:{line} — {violation description} → Fix: {specific fix}

### HIGH (breaks architecture contract)
- [ ] {file}:{line} — {violation description} → Fix: {specific fix}

### MEDIUM (bad practice, won't crash now)
- [ ] {file}:{line} — {violation description} → Fix: {specific fix}

### PASS
- ✓ Layer imports correct
- ✓ Sealed states used
- (list all passing items)
```

---

### Step 4 — Apply Fixes

If the user says "fix it" or "apply fixes":
1. Fix CRITICAL items first — these block compilation
2. Fix HIGH items — these break architecture guarantees
3. Fix MEDIUM items — these improve long-term maintainability
4. Run `flutter analyze` after each fix batch

For each fix, explain what rule was violated and why the fix is correct.

---

## Common Violations and Their Fixes

| Violation | Fix |
|-----------|-----|
| Entity has `fromJson` | Move to model in `data/models/` |
| BLoC calls `_remoteDataSource` directly | Add use case, BLoC calls use case |
| `abstract class` Event | Change to `sealed class` |
| `default:` on sealed switch | Add explicit case for each missing state |
| `registerLazySingleton<ProductBloc>` | Change to `registerFactory` |
| `context.read()` in `initState` | Wrap in `Future.microtask(() { if (!mounted) return; ... })` |
| `context.go('/path')` | Change to `context.goNamed(AppRoutes.xxx)` |
| `state.matchedLocation` | Change to `state.uri.path` |
