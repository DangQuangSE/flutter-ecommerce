# Phase 05: Widget Decomposition

## Requirements

Break the 1632-line `ProductCustomizerPage` into five single-responsibility widgets, move and rename the page to `customizer/presentation/pages/customizer_page.dart`, and update all router references so the final orchestrator `build()` method is 60 lines or fewer.

## Steps

**Pre-step: Audit `_ProductCustomizerPageState` shared fields before any extraction.**
Read the full `_ProductCustomizerPageState` class and list every `setState`-managed field. Categorize each as:
- **Stays in parent** — state shared across multiple widget sections (e.g. `_selectedColorIndex`, `_selectedLayerIndex`)
- **Moves to cubit** — persistent customization state (e.g. layer list, current text content)
- **Becomes widget-local** — transient UI state only one widget needs (e.g. color picker dialog open/closed)

Document this categorization as a comment block at the top of `customizer_page.dart` before extracting any widgets. This prevents producing oversized constructors or silently pushing local UI state into `CustomizerCubit`.

1. Extract the color preset row and custom color picker dialog into `customizer/presentation/widgets/printing_color_picker.dart` — this widget is pure display (accepts `colors`, `selectedColor`, `onColorSelected`; emits nothing to the cubit directly) and should be approximately 80 lines.

2. Extract the T-shirt mockup image and all draggable layer overlays into `customizer/presentation/widgets/canvas_workspace.dart` — reads layer state via callbacks from the parent; approximately 200 lines.

3. Extract the layer list and add/delete layer controls into `customizer/presentation/widgets/layer_editor.dart` — communicates upward via callbacks; approximately 120 lines.

4. Extract the material selector, text editor field, and font/size slider controls into `customizer/presentation/widgets/design_config_panel.dart` — emits changes via callbacks; approximately 150 lines.

5. Extract the price breakdown row and the confirm ElevatedButton into `customizer/presentation/widgets/pricing_footer.dart` — receives `totalPrice` and `onConfirm` as constructor parameters; approximately 60 lines.

6. Move `product/presentation/pages/product_customizer_page.dart` to `customizer/presentation/pages/customizer_page.dart` and rename the class to `CustomizerPage`; refactor `build()` to compose the five widgets above so it is 60 lines or fewer.

7. Remove the `onConfirm` cart logic that was already moved to the router in Phase 03; ensure `CustomizerPage` has zero imports from `features/cart/`.

8. Update `app_router.dart` to reference the new file path and class name; verify the `onConfirm` callback wired in Phase 03 correctly matches the updated constructor signature.

9. Run `dart analyze` and confirm 0 errors; measure `build()` line count and confirm it is 60 or fewer.

## Success Criteria

- Five widget files exist under `lib/features/customizer/presentation/widgets/`
- `lib/features/customizer/presentation/pages/customizer_page.dart` exists with class `CustomizerPage`
- `customizer_page.dart` `build()` method is 60 lines or fewer
- Each widget file is 200 lines or fewer
- `lib/features/product/presentation/pages/product_customizer_page.dart` does not exist
- `customizer/` has zero imports from `features/cart/`
- `dart analyze` reports 0 errors

## Risks

- Decomposing outside-in matters: extracting action widgets (PricingFooter) before display widgets (CanvasWorkspace) can leave temporary compilation gaps — always extract in the order listed in the steps above
- The class rename from `ProductCustomizerPage` to `CustomizerPage` must be applied in `app_router.dart` atomically with the file move to avoid a missing-class error
