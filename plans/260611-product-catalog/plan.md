# Plan: Product Catalog
Status: ✅ Complete
Date: 2026-06-11
Mode: Hard

## Overview
Build a customer-facing product catalog screen in the Flutter app: a paginated, filterable 2-column grid backed by `GET /api/products`, using Bloc for state management with infinite scroll and a full-featured filter bottom sheet. This delivers parity with the existing web frontend's `ProductListResponse` feature set.

## Phases
- [x] Phase 1: Data Layer — Product catalog model + datasource + repository; reuse existing category and brand layers
- [x] Phase 2: Domain Layer — Entities, use cases, filter value object, and DI registration
- [x] Phase 3: Bloc — Events, sealed state with copyWith nullable-clear flags, and infinite scroll + filter logic
- [x] Phase 4: UI Core — Catalog page shell, toolbar, product grid, product card, and skeleton loader
- [x] Phase 5: UI Filter — Filter bottom sheet with 6 sections and active filter chips

## Research Summary
Two researchers contributed findings that have been merged into this plan.

**Existing infrastructure to reuse (not recreate):**
- `CategoryRemoteDataSource` / `CategoryRepository` / `CategoryTreeNode` already exist under `lib/features/category/` and are registered in `injection_container.dart`. The `getTree()` method (`GET /api/categories/tree`) is exactly what the filter bottom sheet needs. No new category files are required.
- `BrandRemoteDataSource` / `BrandRepository` / `BrandEntity` already exist under `lib/features/brand/` and support `getBrands()`. No new brand files are required.
- `PagedResponse<T>` at `lib/core/models/paged_response.dart` is already generic and correct; `isLast` drives infinite scroll termination.
- `DioClient` singleton — use `_dioClient.dio.get(path, queryParameters: params)` pattern as seen in all existing datasource impls.

**What must be replaced/created:**
- `lib/features/product/data/datasources/product_remote_datasource.dart` — current interface has no pagination or filters; replace both the abstract interface and its impl. The existing DI registration (`ProductRemoteDataSource`) will be updated to point to the new impl.
- New customer-facing model, entity, filter VO, use case, and Bloc files — all under `lib/features/product/`.
- Route: the existing `/products` route in `app_router.dart` currently renders `ProductListPage` backed by `ProductBloc`; update it to render `ProductCatalogPage` backed by `ProductCatalogBloc`.

**State design choice:** Use Option A (flat filter fields embedded in `ProductCatalogLoaded`) rather than a nested `ProductCatalogFilter` object, mirroring `AdminProductListSuccess` exactly. Add `clearX: bool = false` flags to `copyWith` for each nullable filter field so individual chips can reset fields to null without the `??` short-circuit bug.

**Bloc pattern:** Mirror `AdminProductListBloc` verbatim — four handlers: initial load, refresh (keep current filter), load-more (append + page increment), filter-changed (reset to page 0). Debounce for the keyword field is handled in the widget layer using a `Timer`, not in the Bloc.

**Color mapping:** Hardcode `productColorMap` as a `const Map<String, Color>` in a shared constants file inside the product presentation layer.

**Page size:** 12 (not 20 like the admin list, not 9 like the web).

## Dependencies
- `lib/features/category/` feature — already exists and registered; `getTree()` endpoint must be accessible without auth
- `lib/features/brand/` feature — already exists and registered; `getBrands()` endpoint must be accessible without auth
- `lib/core/models/paged_response.dart` — already exists, no changes
- `lib/core/di/injection_container.dart` — must be updated in Phase 2
- `lib/app/router/app_router.dart` — must be updated in Phase 2
- Backend `GET /api/products` must accept all filter query params (`keyword`, `categoryId`, `brandId`, `gender`, `productSize`, `color`, `minPrice`, `maxPrice`, `sort`, `page`, `size`)
- Backend `GET /api/categories/tree` and `GET /api/brands` must be public endpoints

## Mobile Responsive Reference (from web FE)
Phased UI mirrors the web FE's mobile breakpoint (< 640px), which is the primary Flutter target:
- **Grid**: 2 columns on phone (web SM = 2 cols at 640px+; web XS = 1 col — Flutter phone uses 2 cols as standard)
- **Filter**: Bottom sheet slides up (web: right-side drawer — Flutter convention is bottom sheet) — full-height `isScrollControlled: true`, Apply/Reset buttons pinned at bottom
- **Toolbar layout**: Search field full-width on top row; filter icon button + sort dropdown on second row (`Column`) — mirrors web's `flex-col` on XS
- **Active filter chips**: Use `Wrap` widget (chips flow to next line) — mirrors web's `flex flex-wrap`; NOT `SingleChildScrollView` horizontal
- **Category section in sheet**: Scrollable `max-h-40` equivalent; auto-closes sheet on selection
- **Brand section**: Scrollable `max-h-32` equivalent, horizontal wrap
- **Size grid**: 4 columns in sheet (web mobile uses 5 cols but Flutter buttons need more room)
- **Color swatches**: 36px diameter circles with `Wrap` layout
- **Product card**: No mobile-specific changes — `p-16`, `aspect 4:5`, consistent font sizes

## Risks
- HIGH: Existing `/products` route renders `ProductListPage` with `ProductBloc` — Phase 2 must audit all 7+ callers (`GlassBottomBar`, `HomePage`, `checkout_success_page`, `checkout_page`, `notification_page`, `cart_page`, `product_detail_page`, `admin_profile_tab`) before cutting over. Keep `ProductBloc` registered in DI until confirmed unused.
- HIGH: `ProductRemoteDataSource` interface replacement must be **additive** — the new interface adds `getCatalogProducts` but keeps existing CRUD method signatures intact. Removing CRUD methods breaks `ProductBloc`, `GetProductsUseCase`, and `AdminBloc` at compile time.
- HIGH: `active_filter_chips.dart` displays `categoryName` and `brandName` — these string values must be stored in `ProductCatalogLoaded` state (denormalized alongside `categoryId`/`brandId`), set at Apply time inside the bottom sheet. The chips widget only reads from Bloc state.
- MEDIUM: `CategoryRemoteDataSource` uses `CategoryApiClient` (its own Dio instance with separate auth) — category tree endpoint may require auth token. Mitigation: verify `GET /api/categories/tree` is publicly accessible; if not, add a separate unauthenticated DioClient path for catalog use.
- MEDIUM: Repositories (`CategoryRepository`, `BrandRepository`) are GetIt `LazySingleton` singletons — access via `sl<CategoryRepository>()`, NOT `context.read<CategoryRepository>()`. The Flutter provider tree does not contain these.
- MEDIUM: `copyWith` nullable-clear bug inherited from `AdminProductListSuccess` pattern — forgetting `clearX` flags means individual chip removal silently no-ops. Mitigation: write one unit test per nullable filter field verifying that the `clearX` path produces `null`.
- LOW: Color name strings from API may not match keys in `productColorMap` (case, spacing). Mitigation: normalise API color strings to lowercase with no spaces before map lookup; fall back to `Colors.grey` for unknown keys.
- LOW: Size sort order (XS < S < M < L < XL < XXL < 3XL < numeric < alphabetic) must be stable across API response changes. Mitigation: hardcode the priority list; any size not in the list sorts to the end alphabetically.

## Design Note (Spec vs Plan divergence)
The spec (`plans/product-catalog/spec.md`) defines a `Cubit` with separate `pendingFilter`/`appliedFilter`. This plan overrides that with a `Bloc` (Option A: flat filter fields on `ProductCatalogLoaded` state), mirroring `AdminProductListBloc`. Pending filter state is managed locally inside the bottom sheet `StatefulWidget`. The spec's Cubit class diagram is superseded by this plan.

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-11
**Phase in progress:** complete
**Status:** All 5 phases implemented, 68 tests pass, code reviewed (WARNING resolved)

### Decisions made this session
- Used `Bloc` with flat filter fields on `ProductCatalogLoaded` state (mirrors `AdminProductListBloc`)
- `copyWith` uses `clearX: bool` flags to null-out nullable filter fields safely
- Filter names (`categoryName`/`brandName`) denormalized on state for active chips display
- `silent: bool` flag on `ProductCatalogFilterChanged` skips skeleton flash for chip removals
- `EquatableMixin` added to `ProductCatalogLoaded` and `ProductCatalogError` for rebuild deduplication
- `_onRefreshed` emits `isLoadingMore: true` transient state to guarantee stream emission even when refreshed data is identical
- Removed `keyword` from `hasActiveFilter` — search bar already shows keyword visually
- `debugLogDiagnostics` gated on `kDebugMode` to avoid leaking routes in release builds
- `static final _inMemoryProducts` moved to instance field to eliminate class-scoped shared state

### Next immediate action
(none — feature complete)
