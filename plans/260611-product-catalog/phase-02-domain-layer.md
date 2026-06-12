# Phase 2: Domain Layer

## Requirements
Deliver all domain-layer contracts and use cases needed by the Bloc: `ProductCatalogEntity`, `GetProductCatalogUseCase`, and the DI + routing wiring that makes `ProductCatalogBloc` injectable and the `/products` route render the new catalog page.

## Steps
1. **Create `ProductCatalogEntity`** in `lib/features/product/domain/entities/`. Mirror the field set of `ProductCatalogModel` but use domain types: `ProductStatus` enum for `status`, `String` for `gender` (keep as-is — the Bloc maps display strings to API values). Extend `Equatable` and implement `props` — same pattern as `AdminProductListEntity`.

2. **Create `GetProductCatalogUseCase`** in `lib/features/product/domain/usecases/`. Accept all filter params (keyword, categoryId, brandId, gender, productSize, color, minPrice, maxPrice, sort, page, size) and delegate to `ProductRepository.getCatalogProducts`. Return `Result<PagedResponse<ProductCatalogEntity>>`. Register as `LazySingleton` in the next step.

3. **Update `product_repository.dart`** (the abstract interface) to add `getCatalogProducts` — keep any existing method declarations that other callers depend on to avoid breaking `ProductBloc`.

4. **Wire DI in `injection_container.dart`**: update the existing `ProductRemoteDataSource` and `ProductRepository` registrations to point to the new impls, register `GetProductCatalogUseCase` as `LazySingleton`, and register `ProductCatalogBloc` as `Factory`. Category and brand repositories are already registered — no changes needed there.

5. **Audit `/products` route callers before updating `app_router.dart`** — grep for all `AppRoutes.productList` usages: `GlassBottomBar`, `HomePage`, `checkout_success_page`, `checkout_page`, `notification_page`, `cart_page`, `product_detail_page`, `admin_profile_tab`. Confirm each caller only navigates to the list page (no widget-specific assumptions). Then replace the route builder to wrap `ProductCatalogPage` in a `BlocProvider` that creates `ProductCatalogBloc` from `sl`. Keep the `/:productId` sub-route intact.

## Success Criteria
- `GetProductCatalogUseCase` call with page 0 and no filters compiles and returns a typed `Result<PagedResponse<ProductCatalogEntity>>`
- `sl<ProductCatalogBloc>()` resolves without throwing at app startup (confirms DI registration)
- Navigating to `/products` in the app renders `ProductCatalogPage` without a runtime error
- `sl<ProductBloc>()` still resolves (existing DI registration for the admin path is intact)

## Risks
- The existing DI block for `ProductRemoteDataSource` is used by both `ProductRepository` (catalog) and indirectly by `ProductBloc` (admin CRUD). If the interface is extended rather than fully replaced, both callers remain valid; if the CRUD methods are removed, `ProductBloc` must be updated or its DI registration removed.
- `app_router.dart` `/products` route change affects the `AppRoutes.productList` named route — any `context.go(AppRoutes.productList)` call site will now land on `ProductCatalogPage`. Audit the home page and nav bar for stale assumptions about what the route renders.
