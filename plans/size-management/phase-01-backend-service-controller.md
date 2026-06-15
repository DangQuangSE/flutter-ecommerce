# Phase 1: Backend Service + Controller

## Requirements
Deliver a fully working REST API for size group management in `java-ecommerce`: an authenticated admin CRUD surface at `/api/admin/size-groups` and an unauthenticated read endpoint at `/api/size-groups`, both backed by a transactional service with a pre-delete usage guard and duplicate-name protection.

## Steps

1. **Create the constant file** `SizeGroupMessageConstant.java` under `com.sport_pro_be.modules.size.constant` — mirror `BrandConstant.java`. Define success messages for create/update/delete/getAll and error strings for not-found-by-id, name-already-exists, and in-use-by-product.

2. **Create DTOs** in `com.sport_pro_be.modules.size.dto`:
   - `SizeOptionRequest` — fields: `name` (NotBlank, size 1–50), `displayOrder` (int, default 0).
   - `SizeGroupRequest` — fields: `name` (NotBlank, size 2–100), `description` (nullable, size max 255), `sizes` (List of `SizeOptionRequest`, may be empty).
   - `SizeOptionResponse` — fields: `id`, `name`, `displayOrder`.
   - `SizeGroupResponse` — fields: `id`, `name`, `description`, `sizes` (List of `SizeOptionResponse`). Use Lombok `@Builder`.

3. **Create the service interface** `ISizeGroupService.java` in `com.sport_pro_be.modules.size.service` — declare: `List<SizeGroupResponse> getAll()`, `SizeGroupResponse create(SizeGroupRequest)`, `SizeGroupResponse update(Long id, SizeGroupRequest)`, `void delete(Long id)`.

4a. **Add derived query to `ProductRepository`** in `com.sport_pro_be.modules.product.repository.ProductRepository` — add the method `boolean existsBySizeGroupId(Long sizeGroupId);`. This is needed by the delete guard in Step 4b. Do this first and confirm the project compiles before proceeding.

4b. **Implement `SizeGroupService.java`** annotated `@Service @RequiredArgsConstructor @Transactional`:
   - `getAll()`: call `sizeGroupRepository.findAll()`, map each to `SizeGroupResponse`.
   - `create()`: guard duplicate name via `sizeGroupRepository.existsByName(request.getName())` — throw `BadRequestException` with the constant message if true. Build a new `SizeGroup`, populate `sizes` by creating `SizeOption` instances linked to the group, persist, return mapped response.
   - `update()`: look up the group by id (throw `ResourceNotFoundException` if absent). Check name uniqueness only when name has changed. Clear `sizeGroup.getSizes()` then repopulate from the request's sizes list (replace-all strategy — safe because `orphanRemoval=true`). Save and return mapped response.
   - `delete()`: look up by id; call `productRepository.existsBySizeGroupId(id)` — if true throw `ConflictException` with the in-use message. Otherwise call `sizeGroupRepository.deleteById(id)`.

5. **Create `AdminSizeGroupController.java`** at `com.sport_pro_be.modules.size.controller`, mapped to `/api/admin/size-groups`:
   - `GET /` — returns `ApiResponse<List<SizeGroupResponse>>` via `service.getAll()`.
   - `POST /` — `@ResponseStatus(CREATED)`, `@Valid @RequestBody SizeGroupRequest`, returns `ApiResponse<SizeGroupResponse>`.
   - `PUT /{id}` — `@Valid @RequestBody SizeGroupRequest`, returns `ApiResponse<SizeGroupResponse>`.
   - `DELETE /{id}` — returns `ApiResponse<Void>`.

6. **Create `SizeGroupController.java`** at `/api/size-groups` (no auth annotation needed — covered by Security config):
   - `GET /` — delegates to `service.getAll()`, returns `ApiResponse<List<SizeGroupResponse>>`.

7. **Update `SecurityConfig.java`** — add `"/api/size-groups/**"` to the `PUBLIC_URLS` array so Flutter can call the public read endpoint without a token.

## Success Criteria
- `GET /api/size-groups` returns 200 with a JSON list (including an empty list when no groups exist) without any Authorization header.
- `POST /api/admin/size-groups` with a valid token and body creates a group and returns 201 with the full response including nested sizes.
- `PUT /api/admin/size-groups/{id}` replaces sizes correctly — existing size options are removed and replaced by the request's list.
- `DELETE /api/admin/size-groups/{id}` on an in-use group returns 400 (or 409) with a readable message, not a 500.
- `DELETE /api/admin/size-groups/{id}` on an unused group returns 200 and the record is gone from `GET`.
- Posting a duplicate group name returns 400 with the name-exists message.
- Spring Security rejects requests to `/api/admin/size-groups/**` without a valid ADMIN JWT (returns 401/403).

## Risks
- Existing `SizeGroup.sizes` being `FetchType.EAGER` means `findAll()` will N+1 if many groups exist; acceptable for admin-only list but consider `@BatchSize(size=50)` on the collection if the number of groups grows beyond 20.
- Replace-all update has a theoretical optimistic-locking gap if two admins edit the same group simultaneously; acceptable risk for low-traffic admin tool.
