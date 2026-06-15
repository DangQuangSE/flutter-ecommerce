# Phase 3: Flutter Domain Layer

## Requirements
Define the pure-Dart domain layer for size groups: entities, abstract repository interface, use cases, and GetIt registration — making the feature independently testable and accessible to the presentation and product-form layers.

Feature root: `lib/features/size/` (consistent with Phase 2 and project conventions).

## Steps

1. **Create entities** in `lib/features/size/domain/entities/`:
   - `size_option_entity.dart` — `SizeOptionEntity extends Equatable` with fields `id` (int?), `name` (String), `displayOrder` (int). No Flutter imports. Include `copyWith` and `props`.
   - `size_group_entity.dart` — `SizeGroupEntity extends Equatable` with fields `id` (int?), `name` (String), `description` (String?), `sizes` (List of `SizeOptionEntity`). Include `copyWith` and `props`.
   - Note: use `SizeGroupEntity` directly as the parameter type for create/update use cases — no separate `SizeGroupParams` wrapper class is needed. `id` is nullable, so the same entity covers both create (id=null) and update (id set) scenarios.

2. **Create repository interface** in `lib/features/size/domain/repositories/size_group_repository.dart` — single abstract interface:
   - `Future<Result<List<SizeGroupEntity>>> getSizeGroups()`
   - `Future<Result<SizeGroupEntity>> createSizeGroup(SizeGroupEntity entity)`
   - `Future<Result<SizeGroupEntity>> updateSizeGroup(int id, SizeGroupEntity entity)`
   - `Future<Result<void>> deleteSizeGroup(int id)`

3. **Create use cases** in `lib/features/size/domain/usecases/` — one file per use case, each a callable class with `call()` delegating to the repository:
   - `get_size_groups_usecase.dart` — `call()` returns `Future<Result<List<SizeGroupEntity>>>`
   - `create_size_group_usecase.dart` — `call(SizeGroupEntity entity)` returns `Future<Result<SizeGroupEntity>>`
   - `update_size_group_usecase.dart` — `call(int id, SizeGroupEntity entity)` returns `Future<Result<SizeGroupEntity>>`
   - `delete_size_group_usecase.dart` — `call(int id)` returns `Future<Result<void>>`

4. **Register all dependencies in `injection_container.dart`** — add a clearly delimited `// Size Group` section:
   - `LazySingleton` for `SizeGroupRemoteDatasource` pointing to `SizeGroupRemoteDatasourceImpl`.
   - `LazySingleton` for `SizeGroupRepository` pointing to `SizeGroupRepositoryImpl`.
   - `Factory` for each of the four use cases.
   - `Factory` for `SizeGroupCubit` (cubit defined in Phase 4 — add its registration here after Phase 4 is done, or leave a `// TODO: SizeGroupCubit — add after Phase 4` placeholder).

5. **Run `dart analyze`** across the whole project and resolve any import or type errors before declaring this phase done.

## Success Criteria
- All entity classes, repository interface, and use cases are importable from other features with no circular dependencies.
- `dart analyze` reports zero errors after this phase.
- `flutter build apk --debug` succeeds (no compile-time failures from the new domain files).
- DI registrations compile without duplicate key errors.
- No `SizeGroupParams` class exists — `SizeGroupEntity` is used directly at all call sites.

## Risks
- `SizeGroupRepositoryImpl` (Phase 2) imports `SizeGroupEntity` (this phase) — implement phases in order, or stub entities in Phase 2 and finalise them here.
- Ensure `equatable` is already in `pubspec.yaml` (it is, used by other entities) — no new dependency needed.
