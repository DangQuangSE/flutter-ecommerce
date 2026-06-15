# Brainstorm: Product Catalog — Listing & Filtering

**Date:** 2026-06-11

## Source Reference
Analyzed web FE at `D:\WorkWithCorn\sport_pro_fe` — Flutter design mirrors web UX adapted to mobile-first patterns.

---

## Ideas Explored

### Pagination approach
- **Page buttons** (như web): next/prev + số trang — quen với web nhưng awkward trên mobile
- **Infinite scroll** ✅ (chosen): cuộn đến cuối tự load thêm — UX mobile chuẩn hơn

### Filter UX trên mobile
- **Bottom sheet** ✅ (chosen): tương đương MobileFilterDrawer của web, full-screen, apply/reset ở bottom
- **Side drawer**: tương đương desktop sidebar — không phù hợp mobile-first
- **Persistent filter bar**: collapse/expand — phức tạp hơn mức cần thiết

### Grid layout
- **2 columns** ✅ (chosen): chuẩn mobile, giống web ở breakpoint sm
- **1 column list**: mất hiệu quả màn hình
- **3 columns**: chữ quá nhỏ trên phone

---

## User's Direction
Làm theo source code web FE — giữ nguyên tất cả filter options, card fields, sort options. Thay page buttons bằng infinite scroll cho mobile-first UX.

---

## Design Decisions

### Product Card (mirror web)
- Ảnh 4:5 aspect ratio
- Brand name (top-left overlay hoặc text row)
- Category name (text)
- Product name (1 dòng, truncate)
- Star rating (averageRating)
- Giá: salePrice + originalPrice gạch ngang + badge "PROMO"

### Filter options (mirror web đầy đủ)
| Filter | Type | Notes |
|--------|------|-------|
| Keyword search | Text input | Debounce 500ms |
| Category | Tree/hierarchical | Expandable parent-child |
| Brand | Single select | Button group |
| Gender | Segmented: ALL/MEN/WOMEN/UNISEX | Map: MEN→MALE |
| Size | Multi-chip grid | Smart dim nếu không có stock |
| Color | Circular swatches (hex) | Diagonal line khi disabled |
| Price range | Min/Max input + presets | Preset: dưới 1M, 1M-3M |

### Sort options (mirror web)
- Newest (default, `id,desc`)
- Price low → high (`id,desc` fallback — BE chưa support)
- Price high → low (`id,desc` fallback)

### Active filter chips
- Hiển thị bên dưới AppBar/search bar
- Mỗi chip có nút X để xóa từng filter
- "Clear All" button khi có ít nhất 1 filter active

---

## Open Questions
- Smart size/color dimming (cần gọi thêm API để lấy available sizes/colors theo filter hiện tại?)
- BE có support price sort thực sự chưa? (web comment nói chưa support)
- Category tree load lần đầu hay lazy load per node?

---

## Risks
1. **Category tree deep nesting**: nếu category có nhiều level thì UI bottom sheet sẽ complex
2. **Performance**: mỗi filter change gọi API lại + debounce 500ms cần quản lý cancellation
3. **Smart dim sizes/colors**: có thể cần thêm endpoint riêng hoặc load master list 200 items như web
