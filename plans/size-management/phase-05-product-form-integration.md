# Phase 5: Product Form Integration

## Requirements
Add a nullable size group dropdown to the product form's Basic Info step, load size groups from the public API in parallel with existing dropdowns, and propagate `sizeGroupId` through all affected layers (state, params, request models, submit call, and edit-mode loading) — while hardening the existing `loadDropdowns()` error path before the third future is added.

## Steps

### Gate: Step 1 must complete and pass before Steps 2–7 begin

1. **Refactor `loadDropdowns()` error path in `AdminProductFormCubit`** (standalone change — commit separately):
   - The current code has an unsafe cast: `(brandResult as ResultFailure<List<BrandEntity>>).failure.message`. This throws a `CastError` if `brandResult` is `Success` but `catResult` is `ResultFailure`.
   - Replace the chained `else` block with individual guards: for each result, `if (result case ResultFailure(:final failure)) { errorMessage = failure.message; break; }`. Collect the first failure message and emit `DropdownStatus.error`.
   - **Checkpoint:** Run `dart analyze` and manually open the product form to verify dropdowns still load correctly before proceeding to Step 2.

2. **Update `AdminProductDetailEntity`** — add `final int? sizeGroupId` field (with `copyWith` and `props` entry). This is needed so `loadForEdit()` can read the value when opening an existing product.
   - File: `lib/features/admin/product/domain/entities/admin_product_detail_entity.dart`
   - Also update the mapping in `AdminProductDetailModel.toEntity()` to populate `sizeGroupId` from the JSON response.
   - File: `lib/features/admin/product/data/models/admin_product_detail_model.dart`

3. **Update `AdminProductFormState`** — add two new fields:
   - `sizeGroups` (List of `SizeGroupEntity`, default `const []`)
   - `sizeGroupId` (int?, default null)
   - Add `sizeGroupId` to `copyWith` with a `clearSizeGroupId` boolean flag (mirrors the `clearCreatedProductId` pattern).
   - Add both fields to `props`.
   - File: `lib/features/admin/product/presentation/cubit/admin_product_form_state.dart`

4. **Update `AdminProductFormCubit` constructor + `loadDropdowns()`**:
   - Add `GetSizeGroupsUseCase getSizeGroupsUseCase` as a new constructor parameter.
   - In `loadDropdowns()`, launch a third parallel future alongside categories and brands using the refactored safe error path from Step 1.
   - On success, populate `sizeGroups` in the state via `copyWith`.
   - File: `lib/features/admin/product/presentation/cubit/admin_product_form_cubit.dart`

5. **Update `loadForEdit()` in `AdminProductFormCubit`** — add `sizeGroupId: entity.sizeGroupId` to the `copyWith` call inside `loadForEdit()`. Without this, editing an existing product silently resets the size group to null.
   - File: `lib/features/admin/product/presentation/cubit/admin_product_form_cubit.dart` (same file as Step 4)

6. **Add `sizeGroupChanged(int? id)` handler in `AdminProductFormCubit`** — a one-liner: `emit(state.copyWith(sizeGroupId: id, clearSizeGroupId: id == null))`.

7. **Propagate `sizeGroupId` through params and request models** — update these six files:
   - `lib/features/admin/product/domain/params/create_product_params.dart` — add `final int? sizeGroupId`.
   - `lib/features/admin/product/domain/params/update_product_params.dart` — add `final int? sizeGroupId`.
   - `lib/features/admin/product/data/models/product_create_request_model.dart` — add `final int? sizeGroupId`; include in `toJson()` conditionally: `if (sizeGroupId != null) 'sizeGroupId': sizeGroupId`.
   - `lib/features/admin/product/data/models/product_update_request_model.dart` — same as above.
   - `AdminProductFormCubit.submitStep1()` create branch — pass `sizeGroupId: state.sizeGroupId` into `CreateProductParams`.
   - `AdminProductFormCubit.submitStep1()` update branch — pass `sizeGroupId: state.sizeGroupId` into `UpdateProductParams`.

8. **Update `AdminProductFormCubit` factory in `injection_container.dart`** (BLOCK item — explicit step):
   - The existing factory for `AdminProductFormCubit` in `injection_container.dart` takes N positional arguments. Add `sl<GetSizeGroupsUseCase>()` as the final argument.
   - File: `lib/app/di/injection_container.dart` (or wherever `AdminProductFormCubit` is registered)
   - **Verify:** Hot-restart the app and navigate to the product create form — a `GetIt` exception here means the DI wiring was not updated.

9. **Add the size group dropdown widget to the Basic Info step UI**:
   - A `DropdownButtonFormField<int?>` populated from `state.sizeGroups`, with a leading "No size group" `DropdownMenuItem` whose value is null.
   - `onChanged` calls `cubit.sizeGroupChanged(value)`.
   - Show the dropdown only when `dropdownStatus == DropdownStatus.loaded`.
   - Extract to a named private widget class to keep `build()` under 50 lines.
   - File: the Basic Info step widget in `lib/features/admin/product/presentation/`

## Success Criteria
- `loadDropdowns()` no longer contains an unsafe cast; it handles any combination of success/failure across all three parallel futures without throwing a `CastError`.
- `AdminProductDetailEntity` has `sizeGroupId` and `loadForEdit()` populates it — editing an existing product that has a size group shows the correct group pre-selected in the dropdown.
- The Basic Info step displays a size group dropdown populated from the API alongside category and brand dropdowns.
- Selecting a size group and saving a product sends `sizeGroupId` in the request body; selecting "No size group" omits the field.
- `dart analyze` reports zero errors across all modified and new files.
- `flutter build apk --debug` succeeds end-to-end.
- Opening the product create form does not throw a `GetIt` exception (DI factory correctly wired).

## Risks
- `AdminProductFormState.props` must include `sizeGroups` and `sizeGroupId`; missing them causes `BlocBuilder` to skip rebuilds.
- The `loadForEdit()` fix (Step 5) depends on `AdminProductDetailEntity.sizeGroupId` existing (Step 2) — do Steps 2 and 5 together, not in isolation.
