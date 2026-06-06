# Phase 1: UI — Gỡ ô Họ và tên

**Covers:** US-1 (P1)  
**testing:** manual only

## Goal

`RegisterPage` chỉ còn email + password; layout/spacing giữ nhất quán.

## Tasks

- [ ] **1.1** Xóa `_nameController`, `dispose`, và toàn bộ block UI (label `HỌ VÀ TÊN`, `TextFormField`, `SizedBox` sau field).
- [ ] **1.2** Cập nhật `_onSubmit`: `AuthOtpRequested` chỉ truyền `email`, `password` (sau Phase 2 — tạm có thể truyền `name: ''` nếu cook từng phase; ưu tiên cook cả 2 phase một lần).
- [ ] **1.3** Cập nhật navigation `RegisterOtpExtra`: bỏ `name` (đồng bộ với Phase 2).
- [ ] **1.4** Kiểm tra visual: khoảng cách giữa tab và email field vẫn hợp lý (không gap thừa).

## Files

| File | Change |
|------|--------|
| `lib/features/auth/presentation/pages/register_page.dart` | Remove name field + controller |

## Done when

- Register form hiển thị 2 field; không reference `_nameController`.
