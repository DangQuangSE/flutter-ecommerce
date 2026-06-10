# Phase 1: State + Cubit Extension

## Requirements
Extend `AdminProductFormState` and `AdminProductFormCubit` to carry multi-step navigation state, loaded dropdown data, and the `createdProductId` returned after Step 1 submission — without breaking any existing behavior consumed by the current flat form page.

Covers: **FR-01**, **FR-06** (domain half), **FR-09** (cubit half)

## Steps
1. Add `currentStep` (int 0–2), `dropdownStatus` enum (idle/loading/loaded/error), `categories` (list of category tree nodes), `brands` (list of brand entities), `createdProductId` (nullable int), and `dropdownErrorMessage` (nullable string) to `AdminProductFormState` and its `copyWith`. Keep all existing fields; default `currentStep` to 0 and `dropdownStatus` to idle.

2. Add `CategoryRepository` and `BrandRepository` as constructor parameters to `AdminProductFormCubit`; update the DI registration in `injection_container.dart` to pass `sl<CategoryRepository>()` and `sl<BrandRepository>()`.

3. Implement `loadDropdowns()` on the cubit: emit loading status, call `CategoryRepository.getTree()` and `BrandRepository.getBrands(size: 100)` in parallel via `Future.wait`, then emit loaded status with both lists — or emit error status (with message) if either call fails. **Do NOT call `loadDropdowns()` from the constructor body.** Instead, call it at the router's `BlocProvider.create` call site: `() => sl<AdminProductFormCubit>()..loadDropdowns()` — this is the established pattern in this codebase (matches `AdminProductDetailCubit` registration) and avoids async work before the BlocProvider is in the widget tree. NOTE: `getBrands(size: 100)` fetches at most 100 brands; stores with >100 active brands will see a truncated list — acceptable for MVP.

4. Add a `retryDropdowns()` method that simply calls `loadDropdowns()` again — used by FR-10 retry button.

5. Replace the existing `submit()` method with `submitStep1()`: keep the same validation logic, but on create-mode success extract `entity.id` from the `Result<AdminProductDetailEntity>` and emit `state.copyWith(createdProductId: entity.id, currentStep: 1)`. **CRITICAL: do NOT emit `isSuccess: true` here.** Reserve `isSuccess: true` exclusively for `completeForm()` (Phase 4 final step). The existing `BlocListener` pops the page on `isSuccess: true` — emitting it at Step 1 would close the form immediately after create. On edit mode, call `UpdateAdminProductUseCase` and emit `state.copyWith(currentStep: 1)` on success — again without `isSuccess: true`.

6. Add `goBack()` (decrements `currentStep` by 1, min 0), `advanceToStep(int)` (for Step 2 "Next" which has no API call), and keep `loadForEdit()` unchanged so Phase 5 can extend it without conflict.

## Success Criteria
- `AdminProductFormState` compiles with all new fields; `copyWith` uses the `clearCreatedProductId` boolean flag pattern (matching existing `clearError` flag) so `reset()` can zero out `createdProductId` — calling `copyWith(createdProductId: null)` alone does NOT clear it due to the null-coalescing pattern.
- Constructing a fresh `AdminProductFormCubit` immediately triggers dropdown loading; after `Future.wait` resolves, `state.dropdownStatus` is `loaded` and `state.categories` / `state.brands` are non-empty (verified in widget test or manual debug print).
- Calling `submitStep1()` in create mode with valid state results in `state.createdProductId != null` and `state.currentStep == 1`.
- Calling `submitStep1()` in edit mode (with `editingId` set) results in `state.currentStep == 1` and no change to `createdProductId`.
- DI container boots without error; `AdminProductFormCubit` factory registration passes the two new repository dependencies.
- No compile errors in existing usages of `AdminProductFormState` fields (`name`, `description`, `categoryId`, `brandId`, `gender`, `status`, `isFeatured`, `isSubmitting`, `errorMessage`, `editingId`).

## Risks
- Adding constructor params to `AdminProductFormCubit` requires updating both the DI factory and any test doubles that construct the cubit directly — check for test files before editing.
- `BrandEntity.id` is nullable; filter brands with `id != null` before storing in state to avoid null-safety issues in the dropdown value binding later.
