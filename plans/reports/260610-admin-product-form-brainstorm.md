# Brainstorm: Admin Product Form — Dropdown & Multi-Step

**Date:** 2026-06-10

## Ideas Explored

- **Chỉ fix dropdown (dismissed):** Thay Category ID + Brand ID text field bằng dropdown, giữ form 1 bước. Nhanh nhưng UX vẫn thiếu — variants và images vẫn phải vào detail page riêng.
- **Form đầy đủ multi-step (chosen):** Step 1 Basic Info (với dropdown) → Step 2 Variants → Step 3 Images. Theo pattern web FE đã hoàn thiện. Tận dụng cubit/use case variants và images đã có sẵn trong codebase.
- **Separate pages cho variants/images:** Navigate sang page riêng sau khi tạo. Bị loại vì user muốn flow liền mạch trong 1 form.

## User's Direction

Form đầy đủ 3 bước: Basic Info → Variants → Images. Dropdowns cho Category và Brand là bắt buộc.
Tham chiếu từ web FE `D:\WorkWithCorn\sport_pro_fe` — pattern đã validate.

## Open Questions

- Variant step: chọn Color từ dropdown (load `/api/colors`) hay nhập text tự do? Codebase đã có `adminColors` route → nên dùng dropdown.
- Image step: max số lượng ảnh per product? BE không giới hạn rõ.
- Khi edit product (existing), step 2 và 3 load variants/images đang có sẵn của product đó.

## Risks

- `AdminProductFormCubit` cần load 3 danh sách (categories, brands, colors) khi init → 3 API calls song song; loading state phức tạp hơn.
- Variant step: auto-generate SKU pattern cần nhất quán với web FE (brand_slug + category_slug + color + size).
- Image upload dùng multipart — cần xử lý file picking trên Android (permission, `image_picker` package).
