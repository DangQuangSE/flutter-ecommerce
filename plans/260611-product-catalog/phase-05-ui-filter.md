# Phase 5: UI Filter

## Requirements
Deliver the full-height filter bottom sheet with all 6 filter sections and the active filter chips row that appears below the toolbar when any filter is applied. Both widgets must support individual filter removal and a full reset, with the bottom sheet maintaining pending (unapplied) state until the user taps Apply.

## Steps
1. **Create `product_filter_bottom_sheet.dart`** as a `StatefulWidget`. On open, copy the current `ProductCatalogLoaded` filter values into local state as the "pending" filter — changes inside the sheet do not dispatch Bloc events until Apply is tapped. The sheet header has a "Xóa tất cả" button (resets all pending fields to null/default) and a close icon. The Apply button at the bottom dispatches `ProductCatalogLoaded` with the pending filter, then closes the sheet. The sheet is full-height (`isScrollControlled: true`, `DraggableScrollableSheet` or `SizedBox(height: screenHeight * 0.9)`).

2. **Implement the Category section** using the `CategoryTreeNode` tree loaded via `CategoryRepository.getTree()` (call once when the sheet opens — cache in the sheet's local state). Render parent nodes as expandable tiles; children are selectable rows with a checkmark. Single selection — tapping a node sets `pendingCategoryId` and collapses other expanded parents.

3. **Implement the Brand, Gender, and Size sections** as follows. Brand: load via `BrandRepository.getBrands()` on open; render as a horizontal scrolling button group, single select. Gender: 4 fixed chips (TẤT CẢ / NAM / NỮ / UNISEX); TẤT CẢ maps to null, others map to MALE / FEMALE / UNISEX. Size: render in the canonical order from `productSizeOrder` constant (Phase 3), 4-column grid of outlined toggle buttons, single select.

4. **Implement the Color and Price Range sections**. Color: render circular swatches (36 px diameter) in a wrap layout using `productColorMap` (Phase 3); selected swatch shows an outer ring and inner dot. Price Range: two `TextFormField` inputs (min / max, numeric keyboard, VND suffix) plus 2 preset buttons ("Dưới 1.000.000₫" fills max=1000000, "1–3 triệu" fills min=1000000 max=3000000). Tapping a preset overwrites both fields; manual edits clear the active preset highlight.

5. **Create `active_filter_chips.dart`** — use a **`Wrap`** widget (mirrors web FE's `flex flex-wrap`) so chips flow to the next line when they overflow. Renders one `FilterChip` for each non-null/non-default filter field from `ProductCatalogLoaded` state. Chip labels:
   - Category: use `state.categoryName` (denormalized String from Phase 3 — no lookup needed)
   - Brand: use `state.brandName` (denormalized String from Phase 3 — no lookup needed)
   - Gender: display label (NAM / NỮ / UNISEX)
   - Size: `state.productSize`
   - Color: `state.color` (capitalized)
   - Price: formatted range string
   Each chip's `onDeleted` dispatches `ProductCatalogFilterChanged(silent: true, clearX: true)` for the relevant field. A "Xóa tất cả" `TextButton` at the start clears all filters. The widget returns `SizedBox.shrink()` when no filters are active.

## Success Criteria
- Opening the filter sheet and changing values without tapping Apply does not change the grid — Bloc state is unchanged until Apply is tapped
- Closing the sheet without tapping Apply and re-opening it shows the previously applied filter values, not the abandoned pending values
- Tapping the Category section renders the full tree from `GET /api/categories/tree`; selecting a child node and tapping Apply reloads the grid with `categoryId` set in the API request
- Each active filter field renders exactly one chip; removing a chip via its X button dispatches an event that reloads the grid without that filter — the chip disappears after the state updates
- "Xóa tất cả" in the chips row clears all filters and reloads — grid returns to the unfiltered default sort `id,desc`
- The Price Range "Dưới 1.000.000₫" preset correctly sets only `maxPrice = 1000000` (minPrice remains null) and the field inputs reflect the values

## Risks
- Category and brand data must be fetched when the sheet opens. Use `sl<CategoryRepository>()` and `sl<BrandRepository>()` (GetIt direct lookup) — these are `LazySingleton` in GetIt, **not** in the Flutter `InheritedWidget`/`BlocProvider` tree. `context.read<CategoryRepository>()` will throw `ProviderNotFoundException` at runtime. The sheet manages local `Future`-based loading state with `FutureBuilder`, calling the repository directly via `sl`.
- The "pending vs applied" filter split means the sheet must receive the current applied filter as a constructor argument (passed in from the page's `BlocBuilder`) and must not read from `context.read<ProductCatalogBloc>()` after opening — the page's state snapshot at open time is the source of truth for initialising pending state.
- If `getTree()` or `getBrands()` fails inside the sheet, show an inline error retry rather than dismissing the sheet, so the user can recover without losing their in-progress filter selections.
