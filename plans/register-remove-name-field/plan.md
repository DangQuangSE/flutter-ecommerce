# Plan: Bỏ ô "Họ và tên" trên màn Đăng ký

**Status:** 🟢 Implemented  
**Date:** 2026-06-04  
**Mode:** Fast  
**Test:** default (manual E2E, no new unit tests)

## Overview

Gỡ trường nhập **Họ và tên** khỏi `RegisterPage` và dọn luồng `name` client-only (BLoC events/states, `RegisterOtpExtra`, snack-bar chào mừng). **Backend không đổi** — `RegisterRequest` chỉ có `email` + `password`.

---

## Scope Challenge

```
# Scope Challenge:
#   Exists?     → Có — register_page.dart + name plumbing trong auth feature
#   Minimum?    → Xóa UI + bỏ tham số name khỏi OTP/register flow (không gửi API)
#   Complexity? → Fast — 1 feature, ~8 file Dart, pattern quen thuộc
#
# Mode: Fast
# Test:  default
```

**Spec Quality Check:** Không có `spec.md` — yêu cầu rõ từ user (bỏ 1 ô nhập).

---

## User Stories

### P1 — Must Have
- **US-1**: Là người dùng mới, tôi chỉ nhập **email** và **mật khẩu** trên tab Đăng ký, không còn ô Họ và tên.
- **US-2**: Luồng OTP → đăng ký → chuyển Login vẫn hoạt động như trước (request OTP, verify, register).

### P2 — Should Have
- **US-3**: Thông báo đăng ký thành công dùng câu chung (không còn `${welcomeName}`).
- **US-4**: Không còn field/state/event `name` thừa trong auth presentation layer (tránh dead code).

### P3 — Nice to Have
- **US-5**: `EditProfilePage` vẫn giữ ô Họ và tên — cập nhật profile sau đăng ký (ngoài scope plan này).

---

## Phases

- [x] Phase 1: UI — Gỡ field và controller trên `RegisterPage`
- [x] Phase 2: Auth flow cleanup — Events, states, bloc, OTP extra, OTP page, router nếu cần

---

## Story ↔ Phase Mapping

| Phase | P1 | P2 | P3 |
|-------|----|----|-----|
| Phase 1 | US-1 | — | — |
| Phase 2 | US-2 | US-3, US-4 | US-5 (không đụng) |

---

## Out of Scope

- Thay đổi `be-ecommerce` (API đã không có `name`)
- `EditProfilePage` / checkout "Họ và tên"
- Auto-login sau đăng ký

---

## Risks

| Risk | Mitigation |
|------|------------|
| Compile lỗi do call site còn `name:` | `dart analyze` sau Phase 2 |
| Deep link `/register/otp` với `extra` cũ trong hot-reload | Full restart app khi test |

---

## Verification (manual)

1. Mở **Đăng ký** → chỉ thấy Email + Mật khẩu.
2. Submit → OTP page → nhập OTP hợp lệ → snack-bar thành công → Login.
3. Resend OTP vẫn hoạt động.
4. `flutter analyze` không lỗi trên `lib/features/auth/`.
