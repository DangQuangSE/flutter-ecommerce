# Phase 5: Integration & Verification

## Goal
Manual E2E on Android emulator with real backend accounts.

**Delivers:** Verification of all P1 stories

---

## Tasks

- [ ] **5.1** Confirm seed data: one ADMIN + one USER (document emails in plan or README).
- [ ] **5.2** Happy path USER: login → `/home` → browse products.
- [ ] **5.3** Happy path ADMIN: login → `/admin` dashboard loads.
- [ ] **5.4** Wrong password → snackbar with backend message.
- [ ] **5.5** Kill app → reopen → still logged in with correct role route.
- [ ] **5.6** Logout → login screen → back button cannot access home.
- [ ] **5.7** `flutter analyze` full project.

---

## Test Suggestions

- Bloc test: login success emits `AuthAuthenticated` with role ADMIN.
- Repository test: maps `role: USER` → `isAdmin == false`.
- Widget test: LoginPage listener navigates to admin route when `isAdmin`.

---

## Dependencies
- All prior phases; backend `docker-compose up`.
