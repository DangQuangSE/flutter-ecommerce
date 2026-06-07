# Phase 5: Integration Verification

## Goal
Manual E2E on Android emulator with real backend + ADMIN account.

**Delivers:** Verify all P1 + P2 stories

---

## Prerequisites

- Backend running at `http://10.0.2.2:8080` (emulator) or device LAN IP
- ADMIN account exists (role `ADMIN` in DB)
- At least 2–3 test orders with varied statuses in DB

---

## Test Checklist

- [ ] **5.1** Login as ADMIN → dashboard loads → tap "XEM TẤT CẢ" → order list loads (not empty if DB has orders).
- [ ] **5.2** Search by phone number or order id → results filter correctly.
- [ ] **5.3** Tap status chip "Đang giao" (`SHIPPED`) → only shipped orders shown.
- [ ] **5.4** Scroll to bottom → next page loads (if total > page size).
- [ ] **5.5** Tap order → detail page shows items, address, payment method, total.
- [ ] **5.6** Change status PENDING → CONFIRMED → success snackbar + UI updates.
- [ ] **5.7** Login as USER → `/admin/orders` redirects away (router guard).
- [ ] **5.8** Backend down → list shows error state with retry.

---

## Commands

```bash
# Backend (be-ecommerce)
./mvnw spring-boot:run

# Flutter (emulator)
cd flutter-ecommerce
flutter run --dart-define=BASE_URL=http://10.0.2.2:8080
```

---

## Acceptance Criteria

- [ ] All P1 checklist items pass.
- [ ] No analyzer errors: `flutter analyze lib/features/admin`
- [ ] No regression on existing admin dashboard tabs (products, profile).

---

## Dependencies
- Phases 1–4 complete.
