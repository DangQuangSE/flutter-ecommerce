# Plan: Bỏ đăng nhập bằng Google (Login)

**Status:** 🟢 Implemented  
**Date:** 2026-06-04  
**Mode:** Fast  
**Test:** default (visual check + `flutter analyze`)

## Overview

Gỡ UI **Đăng nhập bằng Google** (nút placeholder + divider "Hoặc") khỏi `LoginPage`. Không có backend/OAuth — chỉ xóa widget mock.

---

## Scope Challenge

```
# Scope Challenge:
#   Exists?     → Có — OutlinedButton Google + SnackBar placeholder trên login_page.dart
#   Minimum?    → Xóa divider "Hoặc", nút Google, spacing thừa
#   Complexity? → Fast — 1 file presentation
#
# Mode: Fast
# Test:  default
```

**Spec Quality Check:** PASS.

---

## User Stories

### P1 — Must Have
- **US-1**: Màn Đăng nhập không còn nút Google và divider "Hoặc".
- **US-2**: Form email/password + nút "Vào sân" + footer điều khoản vẫn hiển thị bình thường.

### P2 — Should Have
- **US-3**: Khoảng cách layout hợp lý sau khi gỡ (card → footer, không gap lớn thừa).

### P3 — Nice to Have
- **US-4**: Gỡ nút Google trên `RegisterPage` (chỉ nếu user muốn đồng bộ).

---

## Phases

- [x] Phase 1: UI — Gỡ Google + "Hoặc" trên `LoginPage` + `RegisterPage`

---

## Out of Scope

- Implement OAuth Google
- Backend auth changes
- Xóa package `google_fonts` (vẫn dùng cho typography)

---

## Verification

1. Mở Login → không thấy "Hoặc" / nút Google.
2. Đăng nhập email/password vẫn hoạt động.
3. `flutter analyze lib/features/auth/presentation/pages/login_page.dart`
