# Phase 02: Data Layer

## Requirements

Move all three data layer files (datasource interface, datasource implementation, and repository implementation) from `features/product/data/` to `features/customizer/data/`, updating every import path to reference the new domain entities and repository contract locations established in Phase 01.

## Steps

1. Copy `product/data/datasources/custom_design_remote_datasource.dart` to `customizer/data/datasources/` and update its domain entity import to the new `customizer/domain/entities/` path.

2. Copy `product/data/datasources/custom_design_remote_datasource_impl.dart` to `customizer/data/datasources/` and update all imports — entity, datasource interface — to their new paths.

3. Copy `product/data/repositories/custom_design_repository_impl.dart` to `customizer/data/repositories/` and update imports for both the domain repository contract and the datasource interface to their new `customizer/` paths.

4. Grep the entire codebase for any remaining imports pointing at the three original `product/data/` file paths; update any found references before deleting originals. Explicitly check `product/presentation/pages/product_customizer_page.dart` — it imports `custom_design_repository.dart` directly from the old domain path (confirmed) and must be updated here to `customizer/domain/repositories/`.

5. Delete the three original files from `product/data/datasources/` and `product/data/repositories/`.

6. Run `dart analyze` and confirm 0 errors before closing this phase.

## Success Criteria

- `lib/features/customizer/data/datasources/` contains both datasource files
- `lib/features/customizer/data/repositories/` contains the repository implementation file
- `lib/features/product/data/` contains no files with `custom_design` in the name
- `dart analyze` reports 0 errors

## Risks

- Import chains: the repository impl imports the datasource interface which imports the entity — all three import paths must be updated together or the build breaks at this layer boundary
