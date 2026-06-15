# Phase 3: Bloc

## Requirements
Deliver a fully working `ProductCatalogBloc` that handles initial load, infinite scroll, pull-to-refresh, and filter changes — with correct page state, no duplicate items on append, and individual filter fields resettable to null via `copyWith` clear flags.

## Steps
1. **Define `product_catalog_event.dart`** with four sealed event classes:
   - `ProductCatalogLoaded` — initial load + filter apply; carries a full filter snapshot
   - `ProductCatalogLoadMore` — no payload; triggers page+1 append
   - `ProductCatalogRefreshed` — no payload; re-fetches page 0 keeping current filter
   - `ProductCatalogFilterChanged` — carries individual changed field values + `bool silent = false`; when `silent: true` (chip removals) the handler emits `copyWith(isLoadingMore: true)` instead of a full `ProductCatalogLoading` state to avoid skeleton flash; when `silent: false` (keyword debounce) the handler emits `ProductCatalogLoading` first for full skeleton refresh.

2. **Define `product_catalog_state.dart`** with four sealed state classes mirroring `AdminProductListState`: `ProductCatalogInitial`, `ProductCatalogLoading`, `ProductCatalogLoaded` (see field list below), `ProductCatalogError`. For `ProductCatalogLoaded`, embed all filter fields flat:
   - Filter fields: `keyword`, `categoryId`, `brandId`, `gender`, `productSize`, `color`, `minPrice`, `maxPrice`, `sort`
   - **Denormalized name fields** (for active filter chips display): `categoryName: String?`, `brandName: String?` — set when Apply is tapped in the bottom sheet; these allow `active_filter_chips.dart` to show human-readable labels without any repository lookup at chip render time
   - Pagination fields: `products`, `isLoadingMore`, `hasReachedMax`, `currentPage`, `totalElements`
   - Implement `copyWith` with `clearX: bool = false` per nullable filter field (including `clearCategoryId`, `clearBrandId`, `clearCategoryName`, `clearBrandName`, etc.) — when true, sets that field to null regardless of passed value.

3. **Implement `product_catalog_bloc.dart`** — wire the four event handlers. `_onLoaded`: emit Loading, call use case at page 0 with event's filter values, emit Loaded on Success or Error on Failure. `_onRefreshed`: call use case at page 0 with current state's filter values, emit updated Loaded (no Loading flash). `_onLoadMore`: guard on `state is ProductCatalogLoaded && !isLoadingMore && !hasReachedMax`, emit `copyWith(isLoadingMore: true)`, call use case at `currentPage + 1`, on success emit `copyWith(products: [...old, ...new], isLoadingMore: false, hasReachedMax: data.isLast, currentPage: nextPage)`. `_onFilterChanged`: emit Loading, call use case at page 0 with merged new filter values, emit Loaded.

4. **Add `productColorMap` constant** in `lib/features/product/presentation/utils/product_color_map.dart` — a `const Map<String, Color>` with the 13 hardcoded entries. Normalise lookup keys to lowercase trimmed strings at call sites.

5. **Add `productSizeOrder` constant** in the same utils file — a `const List<String>` defining the canonical apparel size order (`XS, S, M, L, XL, XXL, 3XL`). Any size not in the list sorts after these, first numerically then alphabetically. This list drives the Size section rendering order in the filter sheet.

## Success Criteria
- `ProductCatalogLoaded.copyWith(clearCategoryId: true)` produces a state where `categoryId == null`, even when a non-null `categoryId` is also passed in the same call
- Dispatching `ProductCatalogLoadMore` twice in quick succession results in only one in-flight API call (second dispatch is a no-op because `isLoadingMore` is already true)
- After `ProductCatalogRefreshed`, the emitted `ProductCatalogLoaded` state has `currentPage == 0` and the same filter values as before the refresh
- `ProductCatalogFilterChanged` with a new keyword resets `currentPage` to 0 and replaces the `products` list (no append)
- `productColorMap['navy']` resolves to `Color(0xFF001F5B)` (spot check the exact hex values from the spec)

## Risks
- Debounce for keyword input: the Bloc itself has no timer — the widget must manage a `Timer` and only dispatch `ProductCatalogFilterChanged` after 500 ms of inactivity. If a developer moves the debounce into the Bloc event stream they must use `EventTransformer` (e.g. `debounce`) — ensure this is documented in a code comment on the event handler.
- `isLoadingMore` guard must be checked against the current `state` snapshot at the time the event handler runs, not the snapshot captured when the event was dispatched. Use `state is ProductCatalogLoaded && !(state as ProductCatalogLoaded).isLoadingMore` inside `_onLoadMore`.
