# Plan: Validate email UI + thông báo email đã tồn tại (Đăng ký)

**Status:** 🟢 Implemented  
**Date:** 2026-06-04  
**Mode:** Fast  
**Test:** default (`flutter analyze` + test tay E2E)

## Overview

Cải thiện **RegisterPage** và **AuthBloc** để:
1. Kiểm tra **format email** trên UI trước khi gọi API (dùng `StringX.isValidEmail` đã có).
2. Khi backend trả **409** (`Email already exists`) ở bước **request OTP** — hiển thị rõ cho user trên màn Đăng ký (không chuyển sang OTP).

Backend **không đổi** — đã trả 409 tại `requestRegistrationOtp` và `register`.

---

## Scope Challenge

```
# Scope Challenge:
#   Exists?     → Có — validator chỉ check rỗng; 409 chỉ map ở bước register (OTP page)
#   Minimum?    → UI email regex + bloc/listener 409 tại request OTP + message tiếng Việt
#   Complexity? → Fast — auth presentation + 1 extension có sẵn
#
# Mode: Fast
# Test:  default
```

**Spec Quality Check:** Không có `spec.md` — yêu cầu user rõ (format + email tồn tại).

---

## Hiện trạng (gap)

| Bước | Backend | Flutter hiện tại |
|------|---------|------------------|
| Submit Đăng ký → request OTP | 409 nếu email đã có user | `AuthError` + SnackBar (message EN) |
| Email format | 400 `@Email` nếu lỗi | Chỉ check `empty` |
| OTP → register | 409 (hiếm, race) | `AuthRegisterAccountExists` trên **OTP page** ✓ |

**Root cause:** `_onOtpRequested` không tách 409 → `AuthRegisterAccountExists`; `RegisterPage` listener không lắng state đó.

---

## User Stories

### P1 — Must Have
- **US-1**: Nhập email sai format (vd. `abc`, `a@`) → lỗi inline *"Email không đúng định dạng"* trước khi gọi API.
- **US-2**: Email đã đăng ký → khi bấm Đăng ký, thấy thông báo tiếng Việt rõ (không vào màn OTP).

### P2 — Should Have
- **US-3**: Lỗi 409/400/network khác vẫn hiển thị qua SnackBar hoặc inline (ưu tiên inline dưới ô email cho lỗi gắn field).
- **US-4**: Map message backend `Email already exists` → tiếng Việt thống nhất (bloc hoặc helper nhỏ).

### P3 — Nice to Have
- **US-5**: Áp dụng cùng validator email cho `LoginPage` (đồng bộ UX).

---

## Phases

- [x] Phase 1: UI — Validator email trên `RegisterPage`
- [x] Phase 2: Bloc — 409 tại `AuthOtpRequested` / `AuthResendOtpRequested` + message mapper
- [x] Phase 3: Register UX — Listener inline error; reset khi user sửa email

---

## Story ↔ Phase Mapping

| Phase | P1 | P2 | P3 |
|-------|----|----|-----|
| Phase 1 | US-1 | — | — |
| Phase 2 | US-2 | US-4 | — |
| Phase 3 | US-2 | US-3 | US-5 (optional) |

---

## Out of Scope

- Sửa backend message / i18n server
- Đổi luồng OTP hoặc auto-login
- Widget test (trừ khi user yêu cầu)

---

## Risks

| Risk | Mitigation |
|------|------------|
| Message EN từ API không match mapper | Map theo `statusCode == 409` trước, fallback `contains('already exists')` |
| `AuthRegisterAccountExists` emit khi đang ở OTP từ register step | Giữ handler OTP page; Register chỉ xử lý khi `!_hasNavigatedToOtp` |

---

## Verification (manual)

1. Email `not-an-email` → submit → inline lỗi format, không loading.
2. Email đã có tài khoản → submit → thông báo *đã tồn tại*, **không** push `/register/otp`.
3. Email hợp lệ, chưa có account → vẫn vào OTP như cũ.
4. `flutter analyze lib/features/auth/`
