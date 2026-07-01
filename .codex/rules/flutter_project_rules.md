# Codex Flutter Project Rules

These rules are mandatory for every Codex change in this repository.

## Source Of Truth

Before editing Dart code, Codex must read and follow:

- `docs/CODING_STANDARDS_APP.md`
- `docs/flutter-grading-standards.md`

If a local pattern conflicts with these documents, follow the documents unless
the user explicitly approves a different approach.

## Non-Negotiable Gates

- Keep feature code inside the existing Clean Architecture layers:
  `data`, `domain`, `presentation`, plus the feature module for DI.
- UI state must use the existing BLoC/Cubit pattern for feature-level state.
  Use `setState` only for local ephemeral UI state.
- No API calls, repository calls, or business logic in widgets.
- All user-facing strings must come from `AppStrings`.
- Colors must come from `AppColors` or theme APIs.
- Sizes, spacing, and radii must come from `AppSizes` where an existing
  constant fits.
- No raw maps or `dynamic` crossing layers. Map JSON only at datasource/model
  boundaries.
- Use GoRouter route names/constants. Do not scatter hard-coded route strings.
- Dispose every controller/subscription in `dispose`, with `super.dispose()` last.
- After every `await` in a widget, check `mounted` before using `context`.
- Dynamic lists must use `ListView.builder` or `GridView.builder`.
- Add `const` constructors/widgets wherever the code permits.
- Keep build methods small. Extract logical UI sections into widgets when a
  screen grows.
- Avoid dead code, commented-out code, unclear abbreviations, and unrelated
  refactors.

## Before Finishing A Code Task

Codex must run or explicitly report why it could not run:

- `dart format` on touched Dart files, or `dart format .` when scoped format is
  not practical.
- `flutter analyze` or `dart analyze`.
- Focused tests when behavior changes.

Codex must also summarize any remaining risks, especially existing violations
that were observed but are outside the requested scope.
