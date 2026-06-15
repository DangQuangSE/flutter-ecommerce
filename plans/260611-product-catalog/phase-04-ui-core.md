# Phase 4: UI Core

## Requirements
Deliver the main catalog screen, including the page scaffold, search toolbar, 2-column product grid, individual product cards, and the skeleton placeholder shown during the initial load. The screen must be navigable from the `/products` route and support pull-to-refresh and infinite scroll.

## Steps
1. **Create `product_catalog_page.dart`** — the top-level screen widget. It attaches a `ScrollController`, sets up a `BlocBuilder` over `ProductCatalogBloc`, and composes the toolbar, filter chips row, and body area. The scroll listener fires `ProductCatalogLoadMore` when `scrollOffset >= maxScrollExtent * 0.8` and state is `ProductCatalogLoaded` with `!isLoadingMore && !hasReachedMax`. Wrap the body in `RefreshIndicator` that dispatches `ProductCatalogRefreshed`. Show `ProductSkeletonGrid` when state is `ProductCatalogLoading` (initial load only). Show `ProductGrid` when `ProductCatalogLoaded`. Show a centred error message with a Retry button when `ProductCatalogError`.

2. **Create `catalog_toolbar.dart`** as a **`StatefulWidget`** (required for Timer lifecycle). Mobile layout (mirrors web FE XS breakpoint — `flex-col`): search `TextField` full-width on the first row; filter icon button + sort `PopupMenuButton` on the second row (`Row` with `MainAxisAlignment.spaceBetween`). The text field debounces input with `Timer? _debounce` (500 ms) before dispatching `ProductCatalogFilterChanged(silent: false)`. **Dispose the timer in `dispose()`** — `_debounce?.cancel()` — to prevent callbacks on unmounted widgets. Sort options: Mới nhất → `id,desc`, Giá tăng dần → `salePrice,asc`, Giá giảm dần → `salePrice,desc`. Filter icon shows a red dot badge when any filter is active.

3. **Create `product_grid.dart`** — a `GridView.builder` with `crossAxisCount: 2`, `crossAxisSpacing: 12`, `mainAxisSpacing: 12`, `childAspectRatio: 0.62`. Accepts the product list from state. Appends a full-width `CircularProgressIndicator` as the last item when `isLoadingMore` is true. Shows `EmptyState` widget (inline, not a separate file) when `products.isEmpty`.

4. **Create `product_card.dart`** — a single card widget. Layout: image (`CachedNetworkImage`, aspect 4:5, `BoxFit.cover`, with a grey placeholder), then brand name (small, muted), product name (max 1 line, ellipsis), star rating row (5 filled/empty stars from `averageRating`), price row (`salePrice` bold + `originalPrice` struck-through if different + orange "PROMO" badge). Tap triggers navigation to `/products/:id`. All padding and typography follows the existing app theme — do not introduce new `TextStyle` constants.

5. **Create `product_skeleton_grid.dart`** — renders exactly 6 skeleton cards in the same 2-column grid layout as `ProductGrid`. Each skeleton card uses `Container` with a shimmer-effect placeholder (use the existing shimmer package if present in `pubspec.yaml`, otherwise use a static grey container). No API call — purely presentational.

## Success Criteria
- Navigating to `/products` renders the page with a skeleton grid during the first load, then transitions to the product grid once `ProductCatalogLoaded` is emitted
- Scrolling to 80% of the list triggers a `ProductCatalogLoadMore` event exactly once per threshold crossing (not repeatedly on every frame)
- Pull-to-refresh dispatches `ProductCatalogRefreshed` and shows the `RefreshIndicator` spinner
- Typing in the search field does not dispatch any Bloc event until 500 ms after the last keystroke
- A product card with `salePrice < originalPrice` shows both prices and the "PROMO" badge; a card where they are equal shows only `salePrice` with no badge
- Empty state renders the "Không tìm thấy sản phẩm" message and a "Xóa bộ lọc" button when `products.isEmpty`

## Risks
- `ScrollController` must be disposed in the page's `dispose` method to prevent memory leaks — ensure the page is a `StatefulWidget`.
- `CachedNetworkImage` requires the `cached_network_image` package; confirm it is in `pubspec.yaml` before adding the import. If absent, fall back to `Image.network` with `errorBuilder`.
- The 80% scroll threshold may fire multiple events before `isLoadingMore` becomes true if the Bloc emits asynchronously. The scroll listener must also guard locally with a flag or rely on the Bloc guard — document the chosen approach clearly in a comment.
