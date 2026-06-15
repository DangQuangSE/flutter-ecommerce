# Plan: Customizer Feature Extraction

Status: In Progress
Date: 2026-06-14
Mode: Hard

## Overview

Extract the customizer/printing feature from `features/product/` into a standalone `features/customizer/` module following Clean Architecture layers. Decouples CartCubit via callback pattern and decomposes the 1632-line ProductCustomizerPage into 5 focused widgets.

## Phases

- [ ] Phase 01: Domain Skeleton — Create `features/customizer/` directory structure and migrate domain layer files
- [ ] Phase 02: Data Layer — Move datasources and repository implementation to `customizer/data/`
- [ ] Phase 03: Cubit + DI + Router — Move CustomizerCubit, update injection_container.dart and app_router.dart, wire CartCubit callback
- [ ] Phase 04: Printing Constants — Extract magic-number prices into `core/constants/printing_constants.dart`
- [ ] Phase 05: Widget Decomposition — Break 1632-line page into 5 widgets + orchestrator page; rename and move to `customizer/`
- [ ] Phase 06: Final Verification — Run flutter-reviewer agent, validate all spec success criteria

## Research Summary

Migration order follows the safest compile-at-boundary approach: domain first, then data, then presentation/DI/router. Each phase must reach 0 `dart analyze` errors before the next phase begins.

CartCubit coupling is resolved with the Callback pattern (Option A): `ProductCustomizerPage` receives an `onConfirm` callback through its constructor, and the router builder lambda holds the `sl<CartCubit>()` calls. This keeps `customizer/` with zero imports from `features/cart/`.

Widget decomposition follows outside-in order: pure display widgets are extracted first (PrintingColorPicker, CanvasWorkspace), mixed read/emit widgets second (LayerEditor, DesignConfigPanel), and the action widget last (PricingFooter with the confirm button).

The `SharedPreferences.getInstance()` direct call inside CustomizerCubit is flagged as a tech debt item — it is not fixed in this plan to keep scope contained.

## Dependencies

- `.claude/agents/flutter-refactorer.md` — already exists, used by implementor each phase
- `.claude/agents/flutter-reviewer.md` — already exists, invoked in Phase 06
- `plans/customizer-extraction/spec.md` — source of truth for success criteria

## Risks

- HIGH: CustomizerCubit calls `SharedPreferences.getInstance()` directly without injection — flag for followup, do not change in this plan to avoid scope creep
- HIGH: Each phase must compile cleanly before proceeding; skipping `dart analyze` check risks cascading broken imports across phases
- MEDIUM: CustomizerCubit DI registration type (Factory vs LazySingleton) must be confirmed by reading injection_container.dart before Phase 03 proceeds — wrong type causes stale state bugs
- MEDIUM: `app_router.dart` references `ProductCustomizerPage` class name — both the import path and class name must be updated atomically in Phase 05 to avoid a broken intermediate state
- LOW: SharedPreferences key `'customizations'` must remain unchanged to preserve user data across the refactor
