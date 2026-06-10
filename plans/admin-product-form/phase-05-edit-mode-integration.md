# Phase 5: Edit Mode + DI Integration

## Requirements
Wire all 3 cubits into both the create and edit router routes, pre-populate Steps 2 and 3 from the existing `AdminProductDetailEntity` in edit mode, and verify the end-to-end create and edit flows compile and run without regression to the product list or detail pages.

Covers: **FR-09**, router wiring for **FR-06**, **FR-07**, **FR-08** in create mode; regression guard for product list and detail

## Steps
1. Update the `adminProductCreate` route builder in `app_router.dart`: change from a single `BlocProvider` to a `MultiBlocProvider` that also provides `AdminProductVariantCubit` and `AdminProductImageCubit` (both factory instances). These are needed by Steps 2 and 3 in create mode.

2. Update the `adminProductEdit` route builder: it already provides `AdminProductDetailCubit` and `AdminProductFormCubit`; add `AdminProductImageCubit` here (note: `AdminProductVariantCubit` and `ProductColorCubit` were already added in Phase 3). **CRITICAL: do NOT remove or modify the `adminProductDetail` route's `MultiBlocProvider`.** The edit page is pushed on top of the detail page; removing the parent's providers would crash `AdminProductDetailPage` when the user pops back from the edit form. The child edit route gets its own isolated factory instances — this is correct behavior and does not affect the parent's instances.

3. Extend `loadForEdit()` in `AdminProductFormCubit` (or trigger it from the `BlocListener` in `AdminProductFormPage`) to also call `AdminProductVariantCubit.loadFromDetail(entity.variants)` and `AdminProductImageCubit.loadFromDetail(entity.images)` after the form fields are populated. Do this from the page's `BlocListener<AdminProductDetailCubit>` where both sibling cubits are already in scope.

4. Verify the `adminProductDetail` route (the read-only detail page) is unaffected: it provides its own separate instances of `AdminProductVariantCubit` and `AdminProductImageCubit` (already present in the router) and does not share state with the form route.

5. Perform a full create-mode smoke check: open form → dropdowns load → fill Step 1 → "Tiếp theo" → POST creates product → `createdProductId` in state → add variant in Step 2 → "Tiếp theo" → add image in Step 3 → "Hoàn tất" → back to list with success snackbar. Fix any runtime exceptions found.

6. Perform a full edit-mode smoke check: open edit form for an existing product → Step 1 dropdowns pre-select correct category and brand → Step 2 shows existing variants → Step 3 shows existing images → save Step 1 → navigate forward → "Hoàn tất" → back to list with update snackbar. Fix any runtime exceptions found.

## Success Criteria
- `flutter analyze` reports zero errors in all modified files.
- The product list page loads and paginates without regression after the DI change.
- The product detail page (read-only) still renders variants and images correctly.
- Creating a new product end-to-end (all 3 steps) results in a product visible in the admin product list with at least one variant and one image.
- Editing an existing product: the category and brand dropdowns pre-select the product's current category and brand; existing variants and images are shown in Steps 2 and 3; saving changes reflects in the product list.
- No `ProviderNotFoundException` or `BlocProvider.of` errors thrown at runtime for any cubit used in the 3-step form.

## Risks
- The edit route currently nests under `adminProductDetail` (path `/admin/products/:id/edit`) — the `AdminProductVariantCubit` and `AdminProductImageCubit` are provided by the parent `adminProductDetail` builder and may be shared with the detail page's tree. Adding fresh factory instances to the edit route builder creates new, isolated instances (correct behavior); verify that the parent detail page's cubit instances are not accidentally closed when the edit route is pushed on top.
- `loadFromDetail` for variants and images must be called after both the form cubit and the detail cubit have resolved — the `BlocListener<AdminProductDetailCubit>` in `AdminProductFormPage` is the correct place since it fires only when the detail load succeeds, guaranteeing the entity is available.
