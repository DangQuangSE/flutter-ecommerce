# Plan: Admin Product Form — Dropdown & Multi-Step Refactor
Status: In Progress

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-10
**Phase in progress:** phase-03-variants-step
**Status:** Phase 2 complete; starting Phase 3 (Variants Step)

### Decisions made this session
- `submit()` backward-compat alias removed in Phase 2 (no longer needed after page rewrite)
- `DropdownButtonFormField` uses `initialValue:` (not deprecated `value:`) per Flutter 3.33+ API
- `SwitchListTile` uses `activeThumbColor:` (not deprecated `activeColor:`)
- `PopScope(canPop: !needsConfirm)` wraps BlocBuilder — needsConfirm = `createdProductId != null && currentStep < 2`
- `_flattenCategories` is a method on `_Step1BasicInfoFormState` (recursive, depth-based prefix)
- `_Step1BasicInfoForm` is `StatefulWidget` to own `GlobalKey<FormState>`

### Next immediate action
Phase 3: Wire `AdminProductVariantCubit` + `ProductColorCubit` into Step 2; update create route in router to provide both cubits
Date: 2026-06-10
Mode: Hard

## Overview
Refactor the single-page admin product form into a 3-step wizard (Basic Info → Variants → Images) that replaces the raw integer ID inputs with real category and brand dropdowns, wires the existing `AdminProductVariantCubit` and `AdminProductImageCubit` into the step flow, and preserves edit-mode pre-population throughout.

## Phases
- [x] Phase 1: State + Cubit Extension — Extend `AdminProductFormState` with step, dropdown data, and `createdProductId`; add parallel load and `submitStep1` returning entity id; verify `CreateProductUseCase` return type (already confirmed: `Result<AdminProductDetailEntity>`)
- [x] Phase 2: Basic Info UI — Replace the flat form page with `IndexedStack`-based step scaffold, step indicator widget, and Step 1 form with category/brand dropdowns and FR-10 retry
- [x] Phase 3: Variants Step — Wire `AdminProductVariantCubit` into Step 2, render variant list with add/delete, pass `state.createdProductId` at call sites
- [ ] Phase 4: Images Step — Wire `AdminProductImageCubit` into Step 3, image picker with thumbnail preview, upload progress, and "Done" navigation
- [ ] Phase 5: Edit Mode + DI Integration — Pre-populate all 3 steps from existing product detail, update router to provide all 3 cubits in both create and edit routes, end-to-end smoke test

## Research Summary
Primary approach follows the researcher's recommendation:

- `AdminProductFormCubit` becomes the single orchestrator for the 3-step flow. State gains `currentStep` (0–2), `createdProductId` (int?), `categories` (List<CategoryTreeNode>), `brands` (List<BrandEntity>), and a `dropdownStatus` enum (idle / loading / loaded / error).
- `IndexedStack` is used instead of `PageView` so all 3 step widgets stay alive — this directly satisfies the "no state reset on Back" non-functional requirement.
- Categories (`GET /api/categories/tree`) and brands (`GET /api/brands?size=100`) are loaded in parallel via `Future.wait` in cubit `init`.
- Step 1 submit → `POST /api/admin/products` → saves `entity.id` from the returned `AdminProductDetailEntity` into `createdProductId` → advances `currentStep` to 1. `CreateProductUseCase` is already typed `Result<AdminProductDetailEntity>` so no domain layer changes are needed.
- Steps 2 and 3 pass `state.createdProductId!` (or `editingId` in edit mode) to `AdminProductVariantCubit` and `AdminProductImageCubit` call sites.
- Category tree is flattened for the dropdown by recursively walking `CategoryTreeNode.children`, applying a depth-based name prefix (e.g., "-- Child Name") to visually indent hierarchy.
- `ProductColorCubit` + `ProductColorRepository` already exist and are registered in DI; Step 2 will load colors in parallel with cubit init so the variant color field becomes a dropdown rather than a free-text input.
- `image_picker` is already a dependency (imported in `admin_product_image_cubit.dart`), so no pubspec change is needed.

## Dependencies
- `CategoryRepository.getTree()` — already implemented (`CategoryRemoteDataSourceImpl` + `CategoryRepositoryImpl`)
- `BrandRepository.getBrands()` — already implemented (`BrandRemoteDataSourceImpl` + `BrandRepositoryImpl`)
- `ProductColorRepository.getColors()` — already implemented (`ProductColorCubit` uses it)
- `image_picker` package — already in pubspec (confirmed by import in `AdminProductImageCubit`)
- Both `AdminProductVariantCubit` and `AdminProductImageCubit` registered as `registerFactory` in DI — will be provided via `MultiBlocProvider` in router for create route (currently only edit/detail routes provide them)

## Risks
- HIGH (resolved in Phase 3): Router `adminProductCreate` currently only provides `AdminProductFormCubit`; because `IndexedStack` mounts all 3 steps immediately, `AdminProductVariantCubit` and `ProductColorCubit` must be in scope from Phase 3 onward. Router update moved to Phase 3 (not Phase 5).
- HIGH (resolved in Phase 1+2): `submitStep1()` must NOT emit `isSuccess: true` — that would trigger the existing `BlocListener`'s `context.pop()`. Only `completeForm()` in Phase 4 emits `isSuccess: true`.
- HIGH (resolved in Phase 2): Orphan product if form abandoned after Step 1 — `PopScope` in Phase 2 shows confirm dialog and calls `DeleteAdminProductUseCase` before popping.
- HIGH (resolved in Phase 1): `loadDropdowns()` called via `..loadDropdowns()` at `BlocProvider.create`, not in constructor — avoids async race before widget tree mounts.
- HIGH (resolved in Phase 3): `_resolvedProductId()` returns `int?`, never force-unwraps `editingId` — buttons disabled when null.
- MEDIUM: `CategoryTreeNode` uses nested `children` lists; flattening must handle arbitrary depth without stack overflow on malformed data — mitigate by capping recursion depth or using an iterative approach.
- MEDIUM: Edit route currently injects `AdminProductDetailCubit` and `AdminProductFormCubit` only; Step 3 needs `AdminProductImageCubit` pre-loaded with `entity.images`, requiring router update and a `loadFromDetail` call — addressed in Phase 5.
- LOW: `CreateVariantParams` requires a `colorId` (int) not a color name string; the variant form must resolve color selection to an ID via the loaded `ProductColorEntity` list — handled in Phase 3 by using color dropdown backed by `ProductColorCubit`.
- LOW: `BrandEntity.id` is nullable (`int?`) — dropdown value binding must guard against null id and filter out any brand without an id before building items.
