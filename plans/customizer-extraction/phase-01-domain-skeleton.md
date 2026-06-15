# Phase 01: Domain Skeleton

## Requirements

Create the full `lib/features/customizer/` directory tree and migrate all domain layer files from `features/product/` into their new home, leaving `product/domain/` with no customizer-related files.

## Steps

1. Create the eight subdirectories that form the Clean Architecture skeleton under `lib/features/customizer/`: `data/datasources/`, `data/repositories/`, `domain/entities/`, `domain/repositories/`, `domain/usecases/`, `presentation/cubit/`, `presentation/pages/`, and `presentation/widgets/`.

2. Copy `product/domain/entities/customization_entity.dart` to `customizer/domain/entities/customization_entity.dart` and update its package import path to reflect the new feature location.

3. Copy `product/domain/repositories/custom_design_repository.dart` to `customizer/domain/repositories/custom_design_repository.dart` and update the entity import to the new path.

4. Create `customizer/domain/usecases/save_custom_design_usecase.dart` as a thin wrapper around `CustomDesignRepository.saveDesign` that returns a typed result — do not introduce any new logic.

5. Before deleting originals, update the import in `product/presentation/pages/product_customizer_page.dart` (line ~16) to point at the new `customizer/domain/entities/customization_entity.dart` path. Also update its import of `custom_design_repository.dart` if present. This file moves in Phase 05 but its imports must be clean starting from Phase 01 to keep `dart analyze` green.

6. Delete the two original domain files from `product/domain/entities/` and `product/domain/repositories/` only after Step 5 is complete and confirmed.

7. Run `dart analyze` and confirm 0 errors before closing this phase.

## Success Criteria

- `lib/features/customizer/domain/` contains exactly 3 files: `customization_entity.dart`, `custom_design_repository.dart`, `save_custom_design_usecase.dart`
- `lib/features/product/domain/entities/customization_entity.dart` does not exist
- `lib/features/product/domain/repositories/custom_design_repository.dart` does not exist
- `dart analyze` reports 0 errors

## Risks

- Deleting originals before updating all downstream imports breaks the build — always move first, grep for remaining references, then delete
- `product_customizer_page.dart` imports `customization_entity.dart` from the old path (confirmed line ~16) — MUST be updated in Step 5 before deletion or `dart analyze` will fail immediately after Phase 01
