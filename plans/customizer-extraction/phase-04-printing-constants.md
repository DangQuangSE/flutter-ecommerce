# Phase 04: Printing Constants

## Requirements

Centralize all hardcoded printing price and type-ID values into a single constants file under `core/constants/`, then replace every occurrence of those magic numbers in the page file with named references.

## Steps

1. Create `lib/core/constants/printing_constants.dart` with five named constants: `heatTransferCost` (30000.0), `reflectiveDecalCost` (50000.0), `extraLayerCost` (10000.0), `heatTransferId` (1), and `reflectiveDecalId` (2) — declared inside an `abstract final class PrintingConstants`.

2. Grep `product_customizer_page.dart` for all occurrences of the numeric literals `30000`, `50000`, and `10000` to confirm the exact count of replacements needed before editing.

3. Replace all magic-number occurrences in `product_customizer_page.dart` with the corresponding `PrintingConstants.*` references and add the import for the new constants file.

4. Grep the full codebase for any other files that hardcode the same price literals and apply the same replacement if found.

5. Run `dart analyze` and confirm 0 errors before closing this phase.

## Success Criteria

- `lib/core/constants/printing_constants.dart` exists with all five constants
- `product_customizer_page.dart` contains zero occurrences of the numeric literals `30000`, `50000`, or `10000`
- `dart analyze` reports 0 errors

## Risks

- Price literals may appear in test files or other presentation files — grep must cover the full project, not only the page file
