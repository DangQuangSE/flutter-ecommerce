# Phase 2: Flutter Data Layer

## Requirements
Create the data layer for size groups in `flutter-ecommerce`: typed models with JSON serialization, a **single** consolidated datasource covering both the public read endpoint and admin CRUD endpoints, and a repository implementation that maps models to entities using `Result<T>`.

Feature root: `lib/features/size/` (matches Brand/Color/Category pattern — not `admin/size/`).

## Steps

1. **Add API constants** — add `sizeGroups` and `adminSizeGroups` endpoint constants to `lib/core/constants/api_constants.dart` pointing to `/api/size-groups` and `/api/admin/size-groups` respectively.

2. **Create models** in `lib/features/size/data/models/`:
   - `size_option_model.dart` — `SizeOptionModel` with fields `id` (int?), `name` (String), `displayOrder` (int). Implement `fromJson` and `toJson`.
   - `size_group_model.dart` — `SizeGroupModel` with fields `id` (int?), `name` (String), `description` (String?), `sizes` (List of `SizeOptionModel`). Implement `fromJson` (parse nested `sizes` list) and `toJson`.

3. **Create a single consolidated datasource** in `lib/features/size/data/datasources/`:
   - `size_group_remote_datasource.dart` — abstract interface with all five methods:
     - `Future<List<SizeGroupModel>> getSizeGroups()` — calls `GET /api/size-groups` (public, no auth)
     - `Future<SizeGroupModel> createSizeGroup(SizeGroupModel model)` — calls `POST /api/admin/size-groups`
     - `Future<SizeGroupModel> updateSizeGroup(int id, SizeGroupModel model)` — calls `PUT /api/admin/size-groups/{id}`
     - `Future<void> deleteSizeGroup(int id)` — calls `DELETE /api/admin/size-groups/{id}`
   - `size_group_remote_datasource_impl.dart` — implements each method using `DioClient.dio`, parses the `data` field from the `ApiResponse` envelope. Wraps each call in try/catch and rethrows as `DioException`.
   - Note: `getSizeGroups()` uses the public URL constant (no auth header needed — Dio interceptor only adds token when present); all write methods use the admin URL constant.

4. **Create repository impl** `lib/features/size/data/repositories/size_group_repository_impl.dart` — single datasource dependency; wraps each call in `try/catch`, converts `DioException` and `Exception` to `Failure` using the project's error-handling pattern, returns `Result<T>`.

5. **Map models to entities** — in the repository impl, convert `SizeGroupModel` → `SizeGroupEntity` and `SizeOptionModel` → `SizeOptionEntity` (entities defined in Phase 3; use forward-compatible stubs or define entities first).

## Success Criteria
- `SizeGroupModel.fromJson` correctly deserialises a server response including a nested `sizes` array.
- `SizeGroupModel.toJson` produces the payload expected by `POST /api/admin/size-groups` (name, description, sizes as array of objects with name + displayOrder).
- `dart analyze` reports zero errors on all new files in this phase.
- There is exactly one datasource class for size groups — no parallel public/admin split.

## Risks
- The public `GET /api/size-groups` returns a flat JSON array in `data` — confirm response shape with a quick test against the running BE before implementing `fromJson`.
- Phase 3 entities do not exist yet when writing Phase 2; stub them or implement Phase 3 first.
