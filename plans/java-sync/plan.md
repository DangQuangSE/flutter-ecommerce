# Plan: Sync java-ecommerce to match sport_pro_be
Status: Complete
Date: 2026-06-12
Mode: Hard

## Overview
Add all missing fields, entities, and endpoints to `java-ecommerce` (Spring Boot 3, package `com.sport_pro_be`) so its API contract exactly matches the reference backend `sport_pro_be`. No existing behaviour is changed — all additions are strictly additive or backward-compatible.

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-12 22:00
**Phase in progress:** Complete
**Status:** All 5 phases implemented

### Decisions made this session
- `deleteProduct` changed from `repository.delete()` (triggers @SQLDelete) to manual `setStatus(DELETED) + save()` — matches sport_pro_be exactly
- `@SQLRestriction` removed from Product entity; filtering now done in `ProductSpecification` via `includeDeleted` flag
- `restoreProduct` uses simple `findById + setStatus(ACTIVE) + save` — no native queries needed since @SQLRestriction is gone
- `getProductBySlug` now throws 404 for DELETED products (previously filtered by @SQLRestriction automatically)
- `createVariantsBatch` uses `saveAll` in single transaction with `DataIntegrityViolationException` catch for concurrent SKU race

### Next immediate action
None — all phases complete.

## Phases
- [x] Phase 1: Auth — User.isActive — add `isActive` field to User entity, DTO, ProfileService, and AuthService.login enforcement
- [x] Phase 2: Auth — AdminUserController endpoints — add role/active/delete endpoints with proper DTO records + class-level @PreAuthorize
- [x] Phase 3: Size Module — create new `modules/size/` with SizeGroup and SizeOption entities + repositories
- [x] Phase 4: Product — SizeGroup FK + DTO — wire SizeGroup into Product entity, requests, response, and service
- [x] Phase 5: Product — Restore + Batch + includeDeleted — remove @SQLRestriction, add restoreProduct, update ProductSpecification with includeDeleted, add batch variants (ATOMIC — phases 5+6 merged)

## Research Summary
Key decisions made during research:

- **isActive pattern**: Use `@Column(nullable = false, columnDefinition = "boolean default true")` with field initialiser `= true`. User does NOT use `@Builder`, so `@Builder.Default` must NOT be added. Follow the plain-field pattern from `User.emailVerified`.
- **SizeGroup module**: New top-level package `modules/size/` alongside existing modules. No public API controllers needed — entities only.
- **restoreProduct**: JPQL is blocked by `@SQLRestriction("status <> 'DELETED'")` on the Product entity. Both repository methods (`findByIdIncludeDeleted`, `restoreById`) must use `nativeQuery = true`.
- **Batch variants**: Implement with a single `saveAll` call inside one `@Transactional` method — NOT a loop calling `createVariant`, which would evict the cache N times.
- **Role/active DTOs**: Proper Java `record` types (`UpdateUserRoleRequest`, `UpdateUserActiveRequest`) instead of `Map<String, String>`. The spec.md still references `Map` — the research decision overrides it.
- **deleteUser**: Hard-delete via `userRepository.deleteById(userId)`, matching sport_pro_be behaviour.
- **includeDeleted default**: `defaultValue = "true"` — admin list includes deleted products by default.

## Dependencies
- Phase 3 → Phase 4 (SizeGroup entity must exist before Product imports it)
- Phase 1 → Phase 2 (UserProfileResponse.isActive must exist before admin endpoints return it)
- Phase 5 is the merger of original phases 5+6 — all changes in that phase are atomic (remove @SQLRestriction + update ProductSpecification + restoreProduct + batch variants)
- Schema: `spring.jpa.hibernate.ddl-auto=update` confirmed in `src/main/resources/config/database.properties`. Docker volume persists data; new columns/tables apply automatically on next container startup.

## Risks

### Active
- **Phases 5+6 merged into Phase 5**: All changes (remove @SQLRestriction, restoreProduct, ProductSpecification includeDeleted, batch variants) are in one atomic phase — no deployment window risk.
- MEDIUM: `UserProfileResponse` is a `@Builder` record — adding `isActive` changes the constructor arity; fix `mapToResponse` in ProfileService in the same commit (Phase 1).
- MEDIUM: `Product` uses `@Builder` — adding `sizeGroup` without `@Builder.Default` is correct (nullable FK); existing `Product.builder()...build()` calls will get `sizeGroup = null` by default — intended.
- LOW: Cache key for `getProducts` gains `includeDeleted` — invalidates existing cached pages on next restart — harmless.
- LOW: New `size_groups` and `size_options` tables — `ddl-auto=update` creates them automatically; no manual migration needed.

### Noted (from red-team review)
- Hard-delete of `User` with FK references (orders, cart, refresh_tokens) throws `DataIntegrityViolationException` → 500 unless the global exception handler maps it. Confirm whether a handler exists; if not, add a `DataIntegrityViolationException` → 409 mapping. Out of scope for this sync but must not silently 500 in prod.
- `createVariantsBatch` uses `findById` to resolve the parent product — this is intentionally restricted to ACTIVE/INACTIVE products. Callers must restore a DELETED product before adding variants. No code change needed.
- `restoreProduct` on an already-ACTIVE product succeeds silently (UPDATE is a no-op). `@CacheEvict` still runs. Idempotent at the data level; minor cache churn is acceptable.
