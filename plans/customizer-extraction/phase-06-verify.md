# Phase 06: Final Verification

## Requirements

Confirm every success criterion from `plans/customizer-extraction/spec.md` is met, produce a clean `dart analyze` run, pass existing product bloc tests, and receive a PASS or WARNING (not BLOCK) verdict from the `flutter-reviewer` agent.

## Steps

1. Spawn the `flutter-reviewer` agent targeting all files changed across phases 01–05; collect its verdict and severity table.

2. Verify that `lib/features/product/` contains zero files whose content includes the keywords `customizer` or `custom_design` — use a project-wide grep and confirm the result is empty.

3. Verify that `lib/features/customizer/` has the full three-layer structure from spec FR-01: all eight files across `data/`, `domain/`, and `presentation/` directories are present.

4. Measure `customizer_page.dart` `build()` line count and confirm it is 60 or fewer; confirm each of the five widget files is 200 lines or fewer.

5. Confirm `lib/core/constants/printing_constants.dart` exists and that a grep for magic-number price literals (`30000`, `50000`, `10000`) returns no hits inside `customizer/`.

6. Run `flutter test test/features/product/` and confirm all existing bloc tests (including `product_catalog_bloc_test.dart`) pass without modification.

7. Run `dart analyze` across the full project and confirm 0 errors.

8. Produce a sign-off checklist mapping each spec success criterion to its verified result; flag any WARNING items from the reviewer for followup.

## Success Criteria

- `flutter-reviewer` verdict is PASS or WARNING (a BLOCK verdict requires re-opening the relevant phase)
- Grep for `customizer` and `custom_design` in `lib/features/product/` returns no results
- `lib/features/customizer/` contains all 13 files defined in spec FR-01
- `customizer_page.dart` `build()` is 60 lines or fewer; all 5 widget files are 200 lines or fewer
- `core/constants/printing_constants.dart` exists; no price magic numbers remain in `customizer/`
- `flutter test test/features/product/` exits with 0 failures
- `dart analyze` reports 0 errors

## Risks

- A WARNING from flutter-reviewer on the SharedPreferences direct call in CustomizerCubit is expected and acceptable — it is a flagged followup item, not a blocker for this plan
