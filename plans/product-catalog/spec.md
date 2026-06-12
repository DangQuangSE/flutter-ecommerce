# Spec: Product Catalog — Listing & Filtering

**Date:** 2026-06-11
**Status:** Ready

---

## Problem Statement
Người dùng cần duyệt và tìm sản phẩm theo nhiều tiêu chí (category, brand, size, color, gender, price). Flutter app hiện chưa có màn hình catalog — cần xây dựng tương đương web FE tại `sport_pro_fe`.

---

## User Stories

- **[P1]** As a shopper, I want to browse products in a 2-column grid so that I can scan multiple products at once.
  Accepted when: Grid hiển thị đúng 2 cột, mỗi card có ảnh 4:5, brand, tên, rating, giá.

- **[P1]** As a shopper, I want to search products by keyword so that I can find specific items quickly.
  Accepted when: Typing debounces 500ms, grid reload với kết quả mới, page reset về 0.

- **[P1]** As a shopper, I want to filter by category, brand, gender, size, color, and price range so that I can narrow down relevant products.
  Accepted when: Bottom sheet mở với 6 filter sections; applying filter reload grid; active chips hiển thị.

- **[P1]** As a shopper, I want to see active filter chips below the search bar so that I know what's filtered and can remove individual filters.
  Accepted when: Mỗi filter active tạo 1 chip, tap X xóa filter đó và reload.

- **[P1]** As a shopper, I want infinite scroll so that I can load more products by scrolling down.
  Accepted when: Cuộn đến ~80% danh sách tự gọi API page tiếp, loading indicator hiển thị ở bottom.

- **[P2]** As a shopper, I want to sort products by newest / price asc / price desc so that I can order results.
  Accepted when: Dropdown sort trong toolbar thay đổi sort param, grid reload.

- **[P2]** As a shopper, I want to tap a product card to go to product detail so that I can see full info.
  Accepted when: Tap card navigate đến `/products/:id`.

- **[P3]** Smart dim sizes/colors (out of scope — noted for future)

---

## Functional Requirements

1. **FR-01 — Product Grid**: Hiển thị sản phẩm dạng `GridView`, 2 columns, `crossAxisSpacing: 12`, `mainAxisSpacing: 12`.

2. **FR-02 — Product Card fields**: imageUrl (aspect 4:5, `BoxFit.cover`), brandName, categoryName, name (max 1 line), averageRating (5 stars), salePrice + originalPrice (gạch ngang) + badge "PROMO" nếu có discount.

3. **FR-03 — Keyword Search**: `TextField` trong AppBar với debounce 500ms. Clear button khi có text. Trigger reload + reset page.

4. **FR-04 — Filter Bottom Sheet**: `showModalBottomSheet` full-height. Sections theo thứ tự: Category → Brand → Gender → Size → Color → Price Range. Apply button ở bottom. Reset All button ở top-right.

5. **FR-05 — Category Section**: Load tree từ API category. Expandable parent node với toggle. Single selection.

6. **FR-06 — Brand Section**: Load list từ API brand. Button group single-select.

7. **FR-07 — Gender Section**: 4 chips: TẤT CẢ / NAM / NỮ / UNISEX. Map: NAM→MALE, NỮ→FEMALE.

8. **FR-08 — Size Section**: Grid 4 columns. Load `masterSizes` từ API (sorted: XS,S,M,L,XL,XXL trước rồi numeric). Single select.

9. **FR-09 — Color Section**: Grid circular swatches (diameter 36). Map tên màu → hex code. Single select. Selected: ring + center dot.

10. **FR-10 — Price Range Section**: 2 `TextFormField` (min/max, numeric). Quick presets: "Dưới 1.000.000₫", "1.000.000₫ – 3.000.000₫".

11. **FR-11 — Sort Dropdown**: `DropdownButton` hoặc `PopupMenuButton` trong toolbar. Options: Mới nhất / Giá tăng dần / Giá giảm dần.

12. **FR-12 — Active Filter Chips**: `SingleChildScrollView` horizontal bên dưới search bar. `FilterChip` cho mỗi filter active. Nút "Xóa tất cả" khi có ≥1 filter. Không hiện khi không có filter.

13. **FR-13 — Infinite Scroll**: `ScrollController` theo dõi position. Khi `scrollOffset >= maxScrollExtent * 0.8` và không đang loading và còn page tiếp → gọi API page+1, append vào list. `CircularProgressIndicator` ở bottom khi loading more.

14. **FR-14 — Empty State**: Hiển thị khi `products.isEmpty && !loading`. Text "Không tìm thấy sản phẩm" + nút "Xóa bộ lọc".

15. **FR-15 — Loading Skeleton**: Hiển thị 6 skeleton cards khi load lần đầu (initial load).

16. **FR-16 — API Params**: Gọi `GET /products` với params: `page`, `size=12`, `keyword`, `categoryId`, `brandId`, `gender`, `productSize`, `color`, `minPrice`, `maxPrice`, `sort`.

---

## Non-Functional Requirements

- **Performance**: Debounce search 500ms. API response hiển thị trong < 2s (tùy network). Không re-render toàn bộ grid khi append items.
- **UX**: Skeleton loader cho initial load; bottom spinner cho load-more. Filter bottom sheet không reset khi đóng mà chưa apply.
- **State isolation**: Filter state tách biệt "pending" (trong bottom sheet chưa apply) và "applied" (đang active).

---

## Success Criteria

- [ ] Grid 2 cột hiển thị đúng fields từ `ProductListResponse`
- [ ] Tất cả 7 filter options hoạt động và reflect trong API call
- [ ] Active filter chips hiển thị và xóa được từng filter
- [ ] Infinite scroll load page tiếp khi cuộn đến 80% — không duplicate items
- [ ] Debounce search 500ms — không gọi API mỗi keystroke
- [ ] Empty state hiện khi không có kết quả
- [ ] Skeleton loader hiện khi initial load

---

## Out of Scope

- Smart dim sizes/colors theo filter hiện tại (load master list tĩnh)
- Product detail page (chỉ navigate, không implement)
- Wishlist / add-to-cart từ card
- Price sort thực (BE chưa support — dùng fallback `id,desc`)

---

## Assumptions

- API `GET /products` đã có đầy đủ params như web FE đang dùng
- API `GET /categories` trả về tree structure (parent/children)
- API `GET /brands` trả về flat list
- Color hex mapping hardcode trong Flutter (giống web `utils.ts`)
- Size sort order hardcode: XS,S,M,L,XL,XXL,3XL trước, sau đó numeric, sau đó alphabetic

---

## Architecture

```
features/product/
├── data/
│   ├── datasources/     product_datasource.dart (GET /products, /categories, /brands)
│   ├── models/          product_list_response.dart, product_summary.dart
│   └── repositories/    product_repository_impl.dart
├── domain/
│   ├── entities/        product_summary_entity.dart, product_filter.dart
│   ├── repositories/    product_repository.dart
│   └── usecases/        get_products_usecase.dart, get_categories_usecase.dart, get_brands_usecase.dart
└── presentation/
    ├── cubit/           product_catalog_cubit.dart, product_catalog_state.dart
    ├── pages/           product_catalog_page.dart
    └── widgets/
        ├── product_grid.dart
        ├── product_card.dart
        ├── product_filter_bottom_sheet.dart
        ├── active_filter_chips.dart
        ├── catalog_toolbar.dart
        └── product_skeleton_grid.dart
```

### Cubit State Shape
```dart
class ProductCatalogState {
  final List<ProductSummaryEntity> products;
  final ProductFilter appliedFilter;   // filter đang active
  final ProductFilter pendingFilter;   // filter đang edit trong bottom sheet
  final bool isLoading;                // initial load
  final bool isLoadingMore;            // infinite scroll
  final bool hasMore;
  final int currentPage;
  final String? error;
}

class ProductFilter {
  final String? keyword;
  final int? categoryId;
  final int? brandId;
  final String? gender;         // MALE | FEMALE | UNISEX | null (all)
  final String? productSize;
  final String? color;
  final double? minPrice;
  final double? maxPrice;
  final String sort;            // default: 'id,desc'
}
```
