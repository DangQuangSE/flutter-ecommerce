# Phase 3: Variants Step

## Requirements
Replace the Step 2 placeholder with a fully functional variant management view that uses the existing `AdminProductVariantCubit`, allows adding and deleting variants, and passes the correct `productId` (either `state.createdProductId` from a just-created product, or `state.editingId` in edit mode) to every cubit call.

Covers: **FR-07**, **P1 story: add variants**

## Steps
1. Move the router `MultiBlocProvider` update here (do NOT wait until Phase 5). Update both `adminProductCreate` and `adminProductEdit` route builders to provide `AdminProductVariantCubit` and `ProductColorCubit` (call `..loadColors()` at provision time). This is required in Phase 3 — not Phase 5 — because `IndexedStack` keeps `_Step2VariantsForm` alive from the first frame, meaning `context.read<AdminProductVariantCubit>()` is called at build time immediately. Deferring this to Phase 5 would cause `ProviderNotFoundException` during Phases 3 and 4 development. NOTE: `ProductColorCubit` is intentionally kept (not reverted to text input) because `CreateVariantParams.colorId` is a required non-nullable `int` — a free-text color name field cannot satisfy the backend contract.

2. Build the `_Step2VariantsForm` private widget as a `StatelessWidget` that reads `AdminProductVariantCubit` state. Render a `ListView` of existing variants (each row shows SKU, size, color name, price, stock, and a delete icon button). For an empty list, show a "Chưa có biến thể nào" placeholder.

3. Build an "Add Variant" bottom sheet or inline expansion panel (inline preferred to avoid context passing complexity) that contains fields for: color (`DropdownButtonFormField<int>` backed by `ProductColorCubit` loaded list filtered to `colors.where((c) => c.id != null)`, value is `c.id!`, validator requires non-null), size (TextFormField), SKU (TextFormField — admin types this manually; auto-generate SKU is out of scope), original price (TextFormField, numeric), sale price (TextFormField, numeric, optional), stock quantity (TextFormField, integer), and status dropdown. Wrap these in a `Form` with a local key and a "Thêm" button that validates then calls `cubit.createVariant(productId, params)`.

4. Resolve the `productId` to pass to variant cubit calls using a helper method `int? _resolvedProductId(AdminProductFormState state) => state.createdProductId ?? state.editingId` (returns `int?`, NOT force-unwrapped). Disable/hide the "Thêm" variant button when `_resolvedProductId(state) == null` to prevent null-dereference. The `!` operator on `editingId` must never appear — in create mode before Step 1 completes both fields are null and the button should simply be inactive.

5. Handle delete: each variant row's delete button calls `cubit.deleteVariant(variant.id)` directly (no productId needed for delete). Display a `CircularProgressIndicator` in place of the list when `AdminProductVariantState` is `AdminProductVariantLoading`; show a transient error snackbar on `AdminProductVariantFailure`.

6. Add navigation buttons at the bottom of Step 2: a "Quay lại" button calls `formCubit.goBack()` (returns to Step 1), and a "Tiếp theo" button calls `formCubit.advanceToStep(2)` (no validation required per FR-07 — variants are optional). Replace the Step 2 placeholder in `IndexedStack` with this widget.

## Success Criteria
- Entering Step 2 in create mode shows an empty variant list with the "Chưa có biến thể nào" placeholder.
- The color dropdown in the add form shows all colors from the API.
- Filling all required fields and tapping "Thêm" calls `AdminProductVariantCubit.createVariant` with the correct `productId` (matching the id returned from Step 1 submit); the new variant appears in the list.
- Tapping the delete icon on a variant removes it from the list.
- Tapping "Tiếp theo" with an empty variant list still advances to Step 3 (FR-07 allows no variants).
- Tapping "Quay lại" returns to Step 1 without resetting any Step 1 field.

## Risks
- `AdminProductVariantCubit` is registered as `registerFactory` — it must be provided in the `MultiBlocProvider` for the create route by Phase 5; until then, development can be tested only on the edit route where it is already provided. Coordinate with Phase 5 to not break the edit route's existing `AdminProductDetailPage` BlocProvider tree.
- `CreateVariantParams.colorId` is required (non-nullable int) — the color dropdown must prevent "no selection" submission; add a validator that requires a non-null value before the form key validates.
