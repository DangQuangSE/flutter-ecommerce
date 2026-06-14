# Phase 03: Cubit + DI + Router

## Requirements

Move CustomizerCubit and CustomizerState to `customizer/presentation/cubit/`, update `injection_container.dart` to import all five customizer types from their new paths, update `app_router.dart` to wire the CartCubit callback, and patch any other files that import the cubit from the old location.

## Steps

1. Read `injection_container.dart` to confirm whether CustomizerCubit is registered as `registerFactory` or `registerLazySingleton`; record the finding in a code comment — do not change the registration type in this phase regardless of what is found.

2. Copy `product/presentation/cubit/customizer_cubit.dart` and `customizer_state.dart` to `customizer/presentation/cubit/`; update all internal imports in both files to point at the new `customizer/domain/` paths.

3. Delete the two original cubit files from `product/presentation/cubit/` after confirming the copies have correct imports.

4. Update `injection_container.dart`: change the five import paths that reference customizer-related types (CustomizerCubit, CustomDesignRemoteDataSource, CustomDesignRemoteDataSourceImpl, CustomDesignRepository, CustomDesignRepositoryImpl) from `features/product/` to `features/customizer/`.

5. Update `app_router.dart`: change the CustomizerCubit import to its new path; add the `onConfirm` callback to the route builder. **Important**: the callback must read `sl<CartCubit>().state` lazily at call time, not at widget construction time. The lambda is invoked when the user presses the confirm button — not when the route builder runs. Example closure structure:
   ```dart
   onConfirm: (variantId, quantity, customDesignId, oldItemId) async {
     await sl<CartCubit>().addItem(variantId: variantId, quantity: quantity, isReplace: true, customDesignId: customDesignId);
     if (oldItemId != null) await sl<CartCubit>().removeItem(oldItemId);
   },
   ```
   Keep the existing `ProductCustomizerPage` import path unchanged until Phase 05 moves the file.

6. Update all files outside `customizer/` that import the cubit from the old `product/presentation/cubit/` path. **Explicitly confirmed files that must be updated:**
   - `lib/features/product/presentation/pages/product_detail_page.dart`
   - `lib/features/cart/presentation/pages/cart_page.dart`
   - `lib/app/app.dart` (if it imports CustomizerCubit for global BlocProvider)
   Run `grep -r "product/presentation/cubit/customizer" lib/ --include="*.dart" -l` to catch any others.

7. Run `dart analyze` and confirm 0 errors before closing this phase.

## Success Criteria

- `lib/features/customizer/presentation/cubit/` contains both `customizer_cubit.dart` and `customizer_state.dart`
- `lib/features/product/presentation/cubit/` contains no files named `customizer_*`
- `injection_container.dart` has no import from `features/product/` for customizer types
- `app_router.dart` route builder passes `onConfirm` callback; page widget has no direct `CartCubit` import
- `dart analyze` reports 0 errors

## Risks

- If CustomizerCubit is registered as `registerLazySingleton`, note it as a followup item — a singleton cubit retains state across navigation pushes, which may cause stale UI; do not change it here
- The router import for the page file will temporarily reference an old path until Phase 05 — this is acceptable as long as the file still exists at the old path
