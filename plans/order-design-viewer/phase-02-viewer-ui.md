# Phase 02: Viewer UI

**Status:** Implemented; semantic quality approved, analyzer unverified

## Design Constraints

Preflight: Follow existing AppColors/AppSizes/AppStrings, BlocBuilder state views, cached network image, and small stateless widget conventions; preview is authoritative and all controls are immutable/read-only.

- Full-screen viewer resembles the customizer but is strictly read-only.
- Render only the stored preview artwork; metadata drives list/details selection and displays stored coordinates, never a second artwork overlay or unreliable cross-device hit mapping.
- Zoom/pan and side switching are viewing gestures, not design mutations.
- Missing logo files show unavailable status and never crash.

## Quality and Testing State

- **Quality:** Not evaluated.
- **Testing:** Not started; `ck:test` handoff cases cover read-only controls, layer-list selection, fallback, role actions, and 360x640/428x926 layout.
- **Build gate:** `dart analyze` on all new/modified viewer and shared presentation files.

## Steps

1. Build `design_viewer_page.dart` and small viewer widgets with immediate loading/error states and a `LayoutBuilder`-constrained preview viewport using one `InteractiveViewer` transformation source.
2. Add front/back controls enabled only for available previews, preserving independent metadata/fallback behavior per side.
3. Add a selectable layer list and details panel. Text shows side, content, font, color, size, and stored coordinates; logo shows side, stored coordinates, and asset availability. Do not infer hit areas because legacy metadata lacks a canonical canvas extent and logo dimensions.
4. Show a clear preview-only warning for missing/malformed metadata and an empty-layer state when appropriate.
5. Add admin-only “Mở preview” actions using the existing `url_launcher`; validate URLs, handle `launchUrl` failure with `AppStrings` feedback, and omit actions for customers. This is external opening, not guaranteed device download.
6. Reuse safe customizer passive controls/styles where compatible, but keep the preview viewport independent from editable `CustomizerCubit` state and expose no add/edit/move/resize/delete/save controls or callbacks.

## Success Criteria

- Available previews switch, zoom, and pan without mutating design state.
- Every parseable layer is selectable from the list and displays its stored details.
- Preview remains usable for malformed metadata and unavailable local logos.
- Layout is usable at 360x640 and 428x926 without overflow.
- Phase-specific analyze passes and `ck:quality --gate` approves all modified files.

## Spec Coverage

- P1 viewer inspection; P2 admin preview actions.
- FR-05 through FR-11.
- Performance, reliability, layout, and maintainability requirements.
