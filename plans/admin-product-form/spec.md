# Spec: Admin Product Form — Dropdown & Multi-Step

**Date:** 2026-06-10
**Status:** Ready

---

## Problem Statement

Form tạo/sửa sản phẩm admin hiện yêu cầu nhập thủ công `categoryId` và `brandId` dạng số nguyên, dễ nhập sai và không thân thiện. Variants và images không có trong flow tạo mới. Cần refactor thành form 3 bước liền mạch với dropdowns thực tế.

---

## User Stories

- **[P1]** As an admin, I want category and brand shown as searchable dropdowns so that I don't have to memorize integer IDs.
  Accepted when: dropdown hiển thị tên category/brand, submit gửi đúng ID tương ứng.

- **[P1]** As an admin, I want a 3-step form (Basic → Variants → Images) so that I can complete a full product in one flow.
  Accepted when: có step indicator, Next/Back navigation, submit ở bước cuối.

- **[P1]** As an admin, I want to add variants (color + size + price + stock) in Step 2 so that product has purchasable SKUs.
  Accepted when: có thể thêm ≥1 variant, xóa variant, thay đổi price/stock per variant.

- **[P1]** As an admin, I want to upload product images in Step 3 so that products display correctly on storefront.
  Accepted when: có thể chọn ≥1 ảnh từ thiết bị, upload thành công, xem preview.

- **[P2]** As an admin, I want color picker in variant step to load from existing colors list so that color names are consistent.
  Accepted when: dropdown hiển thị colors từ `GET /api/colors` (nếu endpoint tồn tại).

- **[P3]** _(auto-generate SKU từ brand_slug + category_slug + color + size — future)_

---

## Functional Requirements

1. **FR-01:** Khi form mở, cubit gọi song song 2 API: `GET /api/categories/tree` và `GET /api/brands?size=100`. Loading spinner hiển thị trong thời gian chờ.

2. **FR-02:** Category field là `DropdownButtonFormField<int>` hiển thị tên category, value là `id`. Flatten category tree thành list phẳng (dùng tên có indent nếu có parent).

3. **FR-03:** Brand field là `DropdownButtonFormField<int>` hiển thị tên brand, value là `id`.

4. **FR-04:** Step indicator hiển thị 3 bước: "Thông tin" / "Biến thể" / "Hình ảnh". Highlight bước hiện tại.

5. **FR-05:** Step 1 — Basic Info fields: name (required), description, category (dropdown, required), brand (dropdown, required), gender (dropdown: MALE/FEMALE/UNISEX), status (dropdown: ACTIVE/INACTIVE), isFeatured (toggle). Nút "Tiếp theo" validate rồi mới chuyển bước.

6. **FR-06:** Khi Step 1 submit hợp lệ và là create mode: gọi `POST /api/admin/products`, lưu `productId` trả về vào cubit state. Mới navigate sang Step 2.

7. **FR-07:** Step 2 — Variants: tích hợp `AdminProductVariantCubit` hiện có. Hiển thị danh sách variants, có thể thêm (color text + size text + price + stock) và xóa. Nút "Tiếp theo" không bắt buộc có variant (sản phẩm có thể không có variant).

8. **FR-08:** Step 3 — Images: tích hợp `AdminProductImageCubit` hiện có. Chọn ảnh từ gallery (`image_picker`), preview thumbnail, upload `POST /api/admin/products/{id}/images`. Nút "Hoàn tất" → navigate về product list.

9. **FR-09:** Edit mode: load existing categoryId/brandId → pre-select đúng dropdown option; Step 2 load variants hiện có; Step 3 load images hiện có. Step 1 gọi `PUT /api/admin/products/{id}` thay vì POST.

10. **FR-10:** Nếu load categories hoặc brands thất bại, hiển thị error message và nút retry trong form.

---

## Non-Functional Requirements

- **Performance:** Dropdown categories + brands load trong ≤2s trên 4G.
- **UX:** Form không được reset khi quay Back từ Step 2 về Step 1 (giữ state).
- **Scope:** Chỉ sửa trong `lib/features/admin/product/presentation/`. Không tạo route mới.

---

## Success Criteria

- [ ] Form mở ra: dropdown categories hiển thị đúng tên từ API, không còn text field số
- [ ] Form mở ra: dropdown brands hiển thị đúng tên từ API, không còn text field số
- [ ] Step indicator hiển thị 3 bước, highlight đúng bước hiện tại
- [ ] Tạo sản phẩm mới đi qua đủ 3 bước, product + variants + images được lưu thành công
- [ ] Edit sản phẩm: dropdown pre-select đúng category và brand hiện tại
- [ ] Không có compile error, không có regression ở product list page

---

## Out of Scope

- Auto-generate SKU
- Color picker từ API (text input cho color name trong variant là đủ cho P1)
- Drag-and-drop reorder images
- Video upload

---

## Assumptions

- `AdminProductVariantCubit` và `AdminProductImageCubit` đã hoạt động đúng, chỉ cần integrate vào step flow
- `GET /api/categories/tree` trả về đủ data để build dropdown (id + name + parentId)
- `image_picker` package chưa có trong pubspec hoặc đã có — cần kiểm tra trước khi implement Step 3
- Edit mode nhận `productId` qua route parameter (đã có `adminProductEdit` route)
