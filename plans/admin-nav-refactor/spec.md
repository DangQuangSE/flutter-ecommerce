# Spec: Admin Navigation Refactor

**Date:** 2026-06-10
**Status:** Ready

---

## Problem Statement

Tab "Cá nhân" của admin hiện trộn lẫn thông tin cá nhân với 5 management shortcuts, gây nhầm lẫn về mục đích của tab. Tab "Sản phẩm" chiếm một slot riêng trong khi tất cả các mục quản lý khác lại nằm trong Cá nhân — không nhất quán.

---

## User Stories

- **[P1]** As an admin, I want a dedicated "Quản lý" tab so that all management shortcuts are in one predictable place.
  Accepted when: bottom nav tab index 1 shows "Quản lý" label + icon; tapping it shows a vertical list of 6 management items.

- **[P1]** As an admin, I want the "Cá nhân" tab to show only profile info and account settings so that personal and admin concerns are separated.
  Accepted when: "Cá nhân" tab contains no navigation items leading to management pages (brands, colors, categories, coupons, chat).

- **[P1]** As an admin, I want "Quản lý Sản phẩm" accessible from the Quản lý tab so that I don't lose access to product management.
  Accepted when: tapping "Quản lý Sản phẩm" from the Quản lý tab navigates to the existing AdminProductListPage.

- **[P2]** As an admin, I want account settings (e.g. change password) in "Cá nhân" tab.
  Accepted when: at least one settings action is present below profile info. *(Scope TBD in plan)*

---

## Functional Requirements

1. **FR-01:** Tab index 1 label changes from "Sản phẩm" to "Quản lý" with a new icon (e.g. `tune_rounded` or `dashboard_customize_rounded`).
2. **FR-02:** Tab index 1 body renders a vertical `ListView` of management items — same `ListTile` style (icon + label + arrow) as current Cá nhân items.
3. **FR-03:** Management list items in order: Quản lý Sản phẩm → Quản lý Thương hiệu → Quản lý Màu sắc → Quản lý Danh mục → Quản lý Mã giảm giá → Tin nhắn hỗ trợ.
4. **FR-04:** Tapping "Quản lý Sản phẩm" navigates to `AdminProductListPage` (existing page, no change to logic).
5. **FR-05:** Tab index 3 "Cá nhân" removes these 5 items: Quản lý Thương hiệu, Quản lý Màu sắc, Quản lý Danh mục, Quản lý Mã giảm giá, Tin nhắn hỗ trợ.
6. **FR-06:** Tab index 3 "Cá nhân" retains: avatar, tên, email, role badge, "Về Cửa hàng (User View)", Đăng xuất.
7. **FR-07:** Existing `_buildProductsTab()` method (lines 692-889) is renamed `_buildManagementTab()` and its body replaced with the management list — the old product list UI moves to FR-04 navigation target.

---

## Non-Functional Requirements

- **Scope:** Thay đổi chỉ trong `admin_dashboard_page.dart`. Không tạo file mới, không đổi routes.
- **Visual:** List items trong tab Quản lý dùng cùng style với các ListTile hiện tại ở tab Cá nhân (padding, icon color, font).
- **Regression:** Các route `/admin/products`, `/admin/brands`, ... không bị ảnh hưởng.

---

## Success Criteria

- [ ] Bottom nav tab 1 hiển thị nhãn "Quản lý" (không phải "Sản phẩm")
- [ ] Tab Quản lý có đúng 6 mục theo thứ tự FR-03
- [ ] Tab Cá nhân không còn bất kỳ mục quản lý nào (Thương hiệu, Màu sắc, Danh mục, Mã giảm giá, Tin nhắn hỗ trợ)
- [ ] Tapping "Quản lý Sản phẩm" mở đúng AdminProductListPage
- [ ] Không có compile error, không có route 404

---

## Out of Scope

- User (non-admin) bottom nav — không đụng `glass_bottom_bar.dart`
- Thêm màn hình settings mới cho Cá nhân — P2, không nằm trong sprint này
- Thay đổi logic điều hướng GoRouter

---

## Assumptions

- `admin_dashboard_page.dart` là file duy nhất cần sửa
- AdminProductListPage vẫn là destination khi navigate từ "Quản lý Sản phẩm"
- "Về Cửa hàng (User View)" giữ nguyên ở tab Cá nhân
