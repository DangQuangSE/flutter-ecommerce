# Plan: Flutter Login → Spring Boot + Role-Based Routing
Status: 🟢 Implemented (pending manual E2E)
Date: 2026-06-03
Mode: Hard
Test: default

## Overview
Replace mocked `AuthBloc` login with real `POST /api/auth/login`, persist the access token, resolve the user's **role** from the backend (`GET /api/auth/me`), and route **ADMIN** → `adminDashboard`, **USER** → `home`. Reuse existing UI (`LoginPage`) and router guards; fix `UserEntity.isAdmin` to use API role instead of email heuristics.

---

## User Stories

### P1 — Must Have
- **US-1**: As a user, I can log in with email + password against the real API and see backend error messages on failure.
- **US-2**: After successful login, the app stores the access token and attaches it to authenticated API calls.
- **US-3**: After login, the app reads my role; **ADMIN** lands on admin dashboard, **USER** lands on the shopper home experience.
- **US-4**: On app start (`AuthCheckRequested`), if a valid token exists, I am restored as logged-in with correct role routing.

### P2 — Should Have
- **US-5**: Logout calls `POST /api/auth/logout`, clears local tokens, and returns to login.
- **US-6**: Display name on `UserEntity` comes from `GET /api/profiles/me` when available (fallback: email local-part).
- **US-7**: Non-admin users hitting `/admin` are redirected away (router guard — already exists, verify with real role).

### P3 — Nice to Have
- **US-8**: Refresh-token rotation via cookie / stored refresh token (backend sets HttpOnly cookie today).
- **US-9**: 401 interceptor → single refresh attempt → retry (depends on US-8).

---

## Session Notes
**Last active:** 2026-06-03  
**Status:** Code complete — test with real ADMIN/USER accounts on emulator  

### Decisions
- Refresh via `PersistCookieJar` + `dio_cookie_manager`; 401 → auto refresh + retry
- Display name = email local-part (no `/profiles/me`)
- `initialLocation` → `/splash` for session restore
- No seed data added

## Phases
- [x] Phase 1: Token storage + Dio auth interceptor + API constants
- [x] Phase 2: Data & domain — login/me models, repository
- [x] Phase 3: Bloc + session restore + logout
- [x] Phase 4: Splash/router role routing
- [ ] Phase 5: Manual E2E on emulator

---

## Story ↔ Phase Mapping

| Phase | P1 | P2 | P3 |
|-------|----|----|-----|
| 1 | US-2 | — | US-8 (stub) |
| 2 | US-1, US-3 | US-6 | — |
| 3 | US-1, US-3, US-4 | US-5 | US-8 |
| 4 | US-3, US-4 | US-7 | — |
| 5 | all verify | US-5–7 | US-8–9 |

---

## Research Summary

**Chosen (Primary):**
1. `POST /api/auth/login` → parse `data.accessToken` from `ApiResponse`
2. Persist token in `LocalStorage` (`AppConstants.tokenKey`)
3. `GET /api/auth/me` → `role` field (`ADMIN` | `USER`) — **source of truth for routing**
4. Optional `GET /api/profiles/me` for `firstName`/`lastName` display (P2)
5. `UserEntity.isAdmin` → `role.toUpperCase() == 'ADMIN'`
6. Router + `LoginPage` listener already branch on `isAdmin` — update entity only

**Rejected alternatives:**
- Email contains `admin` heuristic — insecure, wrong with real accounts
- Role only from JWT decode — works but duplicates backend; `/me` is simpler and matches RBAC docs
- Add `role` to `LoginSuccessResponse` — requires backend change (out of scope unless user requests)

**Refresh token (mobile):**
- Backend returns refresh in **HttpOnly cookie**, not JSON body.
- **P1:** access-token-only session (re-login when expired).
- **P2:** `cookie_jar` + persist refresh cookie OR backend mobile contract — noted in risks.

---

## Dependencies
- `auth-register-wire` completed (ApiConstants `BASE_URL`, Dio client exist).
- Backend running on `http://10.0.2.2:8080` (Android emulator).
- Test accounts: one `ADMIN`, one `USER` in DB (seed or manual).

---

## Risks

- **HIGH**: Login response has **no role** — must call `/api/auth/me` (or profiles) before emitting `AuthAuthenticated`; bloc handler must be sequential.
- **HIGH**: `DioClient` has no auth header interceptor yet — must add before `/me` works.
- **HIGH**: Circular DI if interceptor needs `AuthBloc` — use `LocalStorage` only in interceptor, not bloc.
- **MEDIUM**: Refresh cookie may not persist on Flutter mobile — document P1 limitation.
- **MEDIUM**: `initialLocation: '/home'` + unauthenticated redirect can flash wrong screen — consider `initialLocation: '/splash'` (optional).
- **LOW**: `/me` returns no `id` string — use JWT `uid` claim or profile `id` for `UserEntity.id`.

### Plan-review mitigations
- Emit `AuthAuthenticated` only after role is known (never after login response alone).
- Clear token on 401 from `/me` during `AuthCheckRequested`.
- Router redirect: authenticated admin on `/home` → redirect `/admin` (add if missing).
