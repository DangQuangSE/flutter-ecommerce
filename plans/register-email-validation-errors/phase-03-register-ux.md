# Phase 3: Register UX — Hiển thị lỗi cho user

**Covers:** US-2, US-3 (P1–P2)  
**testing:** manual E2E

## Goal

User thấy lỗi email đã tồn tại / API ngay trên màn Đăng ký, không bị “im lặng” hoặc chỉ SnackBar EN.

## Tasks

- [ ] **3.1** `RegisterPage` state: `String? _emailApiError` (hoặc dùng `errorText` trên `InputDecoration`).
- [ ] **3.2** `BlocConsumer` listener:
  - `AuthRegisterAccountExists` → set `_emailApiError = state.message`, **không** set `_hasNavigatedToOtp`, không push OTP
  - `AuthError` → set `_emailApiError` hoặc SnackBar (lỗi không gắn email)
  - `AuthOtpSent` → clear `_emailApiError` trước khi navigate
- [ ] **3.3** Hiển thị lỗi dưới ô email (`Text` màu `AppColors.error` hoặc `errorText` trên field).
- [ ] **3.4** `onChanged` email → clear `_emailApiError` khi user sửa.
- [ ] **3.5** SnackBar `AuthRegisterAccountExists` (tùy chọn nếu đã có inline — ưu tiên **một** kênh để tránh trùng).
- [ ] **3.6** Action "Đăng nhập" (TextButton/link) khi email đã tồn tại → `context.goNamed(AppRoutes.login)` (giống OTP page).

## Files

| File | Change |
|------|--------|
| `lib/features/auth/presentation/pages/register_page.dart` | Listener + inline error + optional CTA |

## Done when

- Email trùng → message VI hiển thị trên Register; không chuyển OTP.
- Sửa email → lỗi API biến mất.
- OTP page behavior cho 409 ở bước register **không regress**.
