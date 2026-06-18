# Phase 2: Manual E2E — account switch token verification

## Goal

Xác nhận fix hoạt động trên emulator với luồng đổi account thực tế.

**Delivers:** US-1, US-2, US-3 (verification)

---

## Tasks

- [ ] **2.1** Backend running; có USER + ADMIN accounts.
- [ ] **2.2** Scenario A — logout path:
  1. Login USER (`tienphatgame@gmail.com` or test USER)
  2. Navigate away (optional: open home)
  3. Logout
  4. Login ADMIN
  5. Admin → Quản lý Danh mục → tạo category mới
  6. Dio log: `Authorization: Bearer ...` with JWT `roles: ["ADMIN"]`; response 201
- [ ] **2.3** Scenario B — direct re-login (no logout):
  1. Login USER
  2. Logout **not** performed — use login screen to login ADMIN (if app allows) OR logout first per app flow
  3. Create category → ADMIN token
- [ ] **2.4** Scenario C — regression:
  - Logout → confirm redirect login
  - GET categories on home without auth → 200
- [ ] **2.5** Document result in phase checkbox or PR notes

---

## Acceptance Criteria

- [ ] Scenario A passes (primary bug reproduction path).
- [ ] No 403 on category create when logged in as ADMIN after USER session.
- [ ] No `RenderFlex overflowed` on category management screen during test.

---

## Dependencies

- Phase 1 complete.
