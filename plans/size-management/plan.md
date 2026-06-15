# Plan: Size Group & Size Management
Status: ✅ Complete
Date: 2026-06-15
Mode: Hard

## Overview
Implement full CRUD management for size groups and their child size options across both the `java-ecommerce` backend and the `flutter-ecommerce` app, then wire the size group dropdown into the existing admin product form so that `sizeGroupId` is sent on create and update.

## Phases
- [x] Phase 1: Backend Service + Controller — DTOs, service, admin + public controllers in java-ecommerce
- [x] Phase 2: Flutter Data Layer — models, datasources, repository impls for size groups
- [x] Phase 3: Flutter Domain Layer — entities, repository interfaces, use cases, DI wiring
- [x] Phase 4: Flutter Presentation — SizeGroupCubit, list/form pages, widgets, router + DI registration
- [x] Phase 5: Product Form Integration — add sizeGroupId dropdown to AdminProductFormCubit and all touched files

## Research Summary
The backend already has `SizeGroup` and `SizeOption` JPA entities plus their repositories — no schema changes are needed. The plan mirrors the Brand module exactly for the service/controller layer. `SizeGroup.sizes` uses `CascadeType.ALL + orphanRemoval=true`, so the replace-all update strategy (clear old options, insert new ones) is safe. The Flutter side mirrors `BrandCubit` / `BrandRepository` patterns. The product form cubit's `loadDropdowns()` error-path uses a fragile cast (`as ResultFailure`) that must be refactored before adding a third parallel future; the plan addresses this in Phase 5.

Security config already grants `/api/admin/**` ADMIN-only and the public URL whitelist covers pattern-based paths. Adding `/api/size-groups` to the whitelist requires one line change in `SecurityConfig.java`.

## Nav Placement
Size Group Management là standalone menu item trong admin sidebar/drawer, cùng cấp với Brand, Category — không lồng trong Product Management.

## Dependencies
- `SizeGroup` + `SizeOption` JPA entities and repositories in java-ecommerce must remain as-is (confirmed present).
- Admin JWT auth flow in Flutter must be working (confirmed: exists).
- Phases 2–5 depend on Phase 1 being deployed or mockable.
- Phase 5 depends on Phase 3 (SizeGroupEntity type) and Phase 4 (use case).

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-06-15
**Phase in progress:** phase-05-product-form-integration
**Status:** All 5 phases complete — dart analyze zero errors

### Decisions made this session
- loadDropdowns() unsafe cast fixed with individual `if (result case ResultFailure)` guards for all 3 futures
- sizeGroupId propagated through: AdminProductDetailEntity, AdminProductDetailModel, AdminProductFormState, AdminProductFormCubit, CreateProductParams, UpdateProductParams, ProductCreateRequestModel, ProductUpdateRequestModel, admin_product_repository_impl, DI factory
- _SizeGroupDropdown extracted as private StatelessWidget in product_form_step1_basic_info.dart
- Size group dropdown is optional (nullable int?); "Không có nhóm kích thước" null option always present
- GetSizeGroupsUseCase registered as Factory (not LazySingleton) — shared with SizeGroupCubit factory

### Next immediate action
Code review + git commit

## Risks
- HIGH: Delete guard missing — if a SizeGroup is in use by a product, a hard DELETE will fail at the DB FK level and return an unhandled 500. Mitigation: Phase 1 must add an explicit `productRepository.existsBySizeGroupId(id)` check before deletion and throw `ConflictException` with a user-friendly message.
- HIGH: `loadDropdowns()` error path casts the second result to `ResultFailure` unconditionally — adding a third future breaks this. Mitigation: Phase 5 refactors to check each result individually before casting.
- MEDIUM: `SizeGroup.name` has a unique DB constraint — duplicate name on create/update returns an unhandled constraint violation. Mitigation: Phase 1 service checks `existsByName` before save and throws `BadRequestException` with a clear message.
- LOW: Public endpoint `/api/size-groups` not yet in Spring Security whitelist — returns 403 for unauthenticated Flutter requests. Mitigation: Phase 1 adds the path to `PUBLIC_URLS` in `SecurityConfig.java`.
