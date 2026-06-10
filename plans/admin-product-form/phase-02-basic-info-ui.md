# Phase 2: Basic Info UI

## Requirements
Replace the existing flat `AdminProductFormPage` body with an `IndexedStack`-based 3-step scaffold that includes a step indicator and a fully functional Step 1 form — with real category and brand dropdowns, a loading/error state for dropdown data, and retry capability.

Covers: **FR-01** (UI half), **FR-02**, **FR-03**, **FR-04**, **FR-05**, **FR-10**

## Steps
1. Create a reusable `StepIndicatorWidget` (private to the presentation layer) that accepts the total step count and current step index and renders a row of numbered circles with connecting lines — highlight the active step, dim completed and future steps. This widget reads no cubit state directly; it receives only primitive values as parameters.

2. Create a `DropdownLoadingBody` widget (private) that shows a loading spinner when `dropdownStatus` is loading, an error message with a "Thử lại" button wired to `cubit.retryDropdowns()` when status is error, and returns `null` (renders nothing) when loaded — to be used as a conditional overlay guard in the Step 1 form.

3. Build the Step 1 form as a `_Step1BasicInfoForm` private widget (StatefulWidget to hold a `GlobalKey<FormState>`). Fields: name (TextFormField, required validator), description (TextFormField, optional, 3 lines), `DropdownButtonFormField<int>` for category (items built by flattening `state.categories` tree with depth-based "— " prefix, validator requires non-null), `DropdownButtonFormField<int>` for brand (items from `state.brands` where `id != null`, validator requires non-null), gender dropdown (existing enum values), status dropdown (existing, excluding `deleted`), and `isFeatured` SwitchListTile. The "Tiếp theo" button calls `Form.validate()` first; only if valid does it call `cubit.submitStep1()`.

4. Flatten the `CategoryTreeNode` tree into a `List<({int id, String label})>` using a local recursive helper inside the step widget: root nodes use their plain name, children are prefixed with one "— " per depth level. Keep this logic in the widget file (no separate class needed at this point).

5. Restructure `AdminProductFormPage.build()`: wrap the body in a `Column` containing the `StepIndicatorWidget` (driven by `state.currentStep`) followed by an `Expanded` child containing an `IndexedStack` with `index: state.currentStep` and three child slots — Step 1 form, a placeholder `SizedBox` for Step 2 (Phase 3), and a placeholder `SizedBox` for Step 3 (Phase 4). Guard the entire body with the `DropdownLoadingBody` overlay logic.

6. Update the `BlocListener` for `AdminProductFormCubit`: remove the old `isSuccess` pop-and-snackbar logic (it now only fires in Phase 4 `completeForm()`); instead listen for `currentStep` advancing to 1 and show a brief success snackbar for edit-mode Step 1 saves. Keep the `errorMessage` snackbar listener unchanged.

7. Add a `PopScope` (Flutter ≥3.12) or `WillPopScope` wrapper around the form scaffold. When `state.createdProductId != null && state.currentStep < 2` (i.e., product was created in Step 1 but form is abandoned before completion), intercept the pop and show a confirmation dialog: "Sản phẩm đã được tạo nhưng chưa hoàn tất. Xóa sản phẩm này?" with "Xóa & thoát" and "Tiếp tục". On confirm, dispatch `DeleteAdminProductUseCase(state.createdProductId!)` before popping; on cancel, keep the form open.

## Success Criteria
- App compiles and the admin product create route opens without errors.
- The step indicator renders 3 steps with Step 1 highlighted.
- The category dropdown shows all categories from the API with indented child names; the brand dropdown shows brand names.
- Submitting Step 1 with an empty name shows a validation error inline (not a snackbar).
- Submitting a valid Step 1 in create mode results in `state.currentStep == 1` (Step 2 placeholder becomes active in `IndexedStack`).
- Navigating Back to Step 1 from Step 2 (via `cubit.goBack()`) does not reset any Step 1 field values.
- If the dropdown API call fails, an error message and "Thử lại" button render in place of the spinner; tapping retry re-triggers the load.

## Risks
- `IndexedStack` keeps all children in the widget tree simultaneously; Step 2 and Step 3 placeholders must not call any cubit methods on build (they are inert `SizedBox` widgets until Phases 3–4 replace them).
- The existing `BlocListener` for `isSuccess` triggers `context.pop()` — this must be removed or gated to only fire at the final step, otherwise the form will be dismissed after Step 1 submit in create mode.
