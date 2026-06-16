# Phase 1: Remove Order Detail Card

**Goal:** Màn success chỉ còn phần xác nhận — không card chi tiết.

**Covers:** US-1, US-2

---

## Tasks

- [ ] Remove `orderReference` local variable
- [ ] Remove Transaction Detail `Container` widget block
- [ ] Remove `_buildInvoiceRow` helper entirely
- [ ] Keep: success icon, `XÁC NHẬN THÀNH CÔNG`, subtitle paragraph, `TIẾP TỤC MUA SẮM` button
- [ ] Run `dart analyze` on file

---

## Files

| Action | Path |
|--------|------|
| MODIFY | `lib/features/checkout/presentation/pages/checkout_success_page.dart` |
