# Plan: Checkout Success Page — Simplify Order Info Card

**Status:** Complete  
**Mode:** Fast  
**Test:** --no-test

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-16
**Phase in progress:** (none — complete)
**Status:** Card simplified to 2 rows; status = "Đang xử lý"; dart analyze clean.

### Decisions made this session
- Removed `isSuccessColor` from `_buildInvoiceRow` (unused after row removal)
- Kept mock order reference `#SP-{timestamp}` — out of scope

---

## Phases

- [x] **Phase 1:** Sửa `checkout_success_page.dart`
