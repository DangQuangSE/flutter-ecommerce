# Brainstorm: Admin Navigation Refactor

**Date:** 2026-06-10

## Ideas Explored

- **Tab Quản lý riêng (chosen)** — thay tab "Sản phẩm" bằng "Quản lý", chứa toàn bộ management shortcuts + sản phẩm. Tab Cá nhân chỉ còn info + settings.
- **Admin drawer/hamburger** — không đụng bottom nav, thêm menu riêng. Bị loại: thêm gesture layer, không nhất quán với UX hiện tại.
- **Giữ tab Sản phẩm, thêm tab thứ 5** — bottom nav 5 tab. Bị loại: quá chật trên màn hình nhỏ.

## User's Direction

Thay tab "Sản phẩm" (index 1) bằng tab "Quản lý" chứa list dọc các mục quản lý (Sản phẩm, Thương hiệu, Màu sắc, Danh mục, Mã giảm giá, Tin nhắn hỗ trợ). Tab "Cá nhân" giữ lại info + settings + logout, bỏ các management item.

## Open Questions

- "Một số cài đặt" trong Cá nhân cụ thể là gì? (đổi mật khẩu? thông báo?) — /ck:plan cần làm rõ hoặc để P2.
- "Về Cửa hàng (User View)" giữ trong Cá nhân hay chuyển sang Quản lý?

## Risks

- `admin_dashboard_page.dart` là 1713 dòng — thay đổi dễ conflict nếu có branch song song.
- Tab "Sản phẩm" cũ chứa `_buildProductsTab()` (~200 LOC, lines 692-889) — cần giữ nguyên logic, chỉ chuyển điểm truy cập.
