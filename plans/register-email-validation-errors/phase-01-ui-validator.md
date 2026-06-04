# Phase 1: UI — Validator email

**Covers:** US-1 (P1)  
**testing:** manual

## Goal

Chặn submit khi email không đúng format, dùng extension có sẵn.

## Tasks

- [ ] **1.1** Import `package:flutter_ecommerce/core/utils/extensions/string_extensions.dart` trong `register_page.dart`.
- [ ] **1.2** Cập nhật `TextFormField` email `validator`:
  - Rỗng → `'Vui lòng nhập email'`
  - `!value.trim().isValidEmail` → `'Email không đúng định dạng'`
- [ ] **1.3** (Optional US-5) Lặp validator tương tự trên `login_page.dart`.

## Files

| File | Change |
|------|--------|
| `lib/features/auth/presentation/pages/register_page.dart` | Email validator |
| `lib/features/auth/presentation/pages/login_page.dart` | Optional parity |

## Done when

- Form không validate khi email sai format; không dispatch `AuthOtpRequested`.
