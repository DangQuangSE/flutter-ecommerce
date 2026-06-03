# Phase 2: Data & Domain — Login + Me + Profile

## Goal
Implement real HTTP for login and user identity resolution (role + display fields).

**Delivers:** US-1, US-3 (data layer), US-6 (optional profile fetch)

---

## Tasks

- [ ] **2.1** Create `LoginResponseModel` parsing `ApiResponse.data`: `tokenType`, `accessToken`, `expiresInSeconds`, `email`.
- [ ] **2.2** Create `AuthMeModel` from `/api/auth/me` data: `email`, `role`, `tier`, `totalSpending`.
- [ ] **2.3** Create `UserProfileModel` from `/api/profiles/me` (P2): `id`, `email`, `firstName`, `lastName`, `avatar`, `role`.
- [ ] **2.4** Add `AuthLocalDataSource` for token read/write (delegates to `AuthTokenStorage`).
- [ ] **2.5** Update `AuthRemoteDataSource`: `login` real POST; `fetchMe()` GET; `fetchProfile()` GET (best-effort); `logout` POST.
- [ ] **2.6** Add `mapToUserEntity(AuthMeModel me, {UserProfileModel? profile})` → `UserEntity` with `role`, `isAdmin` from role.
- [ ] **2.7** Update `AuthRepository.login`: login → save token → fetchMe → (optional) fetchProfile → return `UserEntity`.
- [ ] **2.8** Update `AuthRepository.getCurrentUser`: read token → if null return null → fetchMe → map entity; on 401 clear token.
- [ ] **2.9** Add `UserRole` enum or `String role` on `UserEntity`; change `isAdmin` getter to `role == 'ADMIN'`.

---

## Files to Touch

| File | Change |
|------|--------|
| `lib/features/auth/data/models/login_response_model.dart` | **New** |
| `lib/features/auth/data/models/auth_me_model.dart` | **New** |
| `lib/features/auth/data/models/user_profile_model.dart` | **New** (P2) |
| `lib/features/auth/domain/entities/user_entity.dart` | Add `role` field |
| `lib/features/auth/data/datasources/auth_local_datasource.dart` | **New** |
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | login, me, logout |
| `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart` | Implement |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Orchestrate login + me |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Adjust if needed |

---

## Acceptance Criteria

- [ ] Login with valid credentials returns `Success(UserEntity)` with `role` from API.
- [ ] Invalid credentials return `AuthFailure` / `NetworkFailure` with backend `message`.
- [ ] `getCurrentUser` returns null when no token stored.
- [ ] Admin test user has `isAdmin == true`; regular user `false`.

---

## Dependencies
- Phase 1 complete (auth interceptor + token storage).
