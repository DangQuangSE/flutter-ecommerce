# Phase 01: Data and domain

**Status:** Implemented; semantic quality approved, analyzer unverified

## Design Constraints

Preflight: Follow existing customizer repository/Result/DioClient/GetIt conventions; keep parsing pure and per-entry tolerant; use sealed immutable Cubit states; all UI strings remain outside this phase.

- Stored rendered previews are the visual truth.
- Keep front/back metadata nullable/raw-safe and parse each side independently.
- Customer requests use `/api/custom-designs/{id}`; admin requests use `/api/admin/custom-designs/{id}`.
- Do not upload, recover, or persist logo assets.

## Quality and Testing State

- **Quality:** Not evaluated.
- **Testing:** Not started; `ck:test` handoff cases are endpoint choice, complete response mapping, and per-entry tolerant metadata parsing.
- **Build gate:** `dart analyze` on customizer data/domain/presentation state and DI files changed by this phase.

## Steps

1. Extend `existing_design_entity.dart`, the datasource response record, and repository mapping with `designImageUrl` and `backDesignImageUrl`, retaining metadata/material/count/price fields.
2. Add `DesignViewerRole { customer, admin }`, a role-aware repository/use-case method, `ApiConstants` admin design-detail path, and datasource selection between `/api/custom-designs/{id}` and `/api/admin/custom-designs/{id}` without accepting an arbitrary URL.
3. Add a pure parser beside the design-layer model. Accept a JSON list per side; decode each map independently through guarded `DesignLayer.fromJson`, skip only invalid entries (missing/bad id, type, enum, color, or coordinates), retain valid siblings, and collect a limited-detail warning per side for null/empty/malformed/legacy input.
4. Add dedicated `design_viewer_cubit.dart` and immutable `design_viewer_state.dart` for load, side selection, layer selection, fallback, and failure. Register factory/use-case dependencies in `injection_container.dart`; expose no persistence operation.

## Success Criteria

- Both roles produce the same complete viewer entity through their required endpoints.
- Invalid metadata never prevents a valid preview from reaching loaded state.
- Cubit exposes only viewing state changes and no save/edit/persistence operations.
- Phase-specific analyze passes and `ck:quality --gate` approves all modified files.

## Spec Coverage

- P1 admin/customer loading and layer inspection.
- FR-03, FR-04, FR-07, FR-08, FR-09, FR-11.
- Security and reliability requirements.

## Session Notes

- Implemented all four phase steps on 2026-07-12.
- Build gate command: `dart analyze lib/features/customizer lib/core/constants/api_constants.dart`.
- Blocker: Dart analyzer produced no output and remained running for more than 60 seconds; the process was terminated. Quality gate was not run because the mandatory build gate did not complete.
- Files: `api_constants.dart`, customizer entity/datasource/repository/usecase/module, metadata parser, and viewer Cubit/state.
