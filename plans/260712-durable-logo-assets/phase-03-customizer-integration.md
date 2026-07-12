# Phase 3: Customizer UI Integration

## Goal

Integrate logo upload/delete into the customizer UI: upload on image pick (with loading feedback), create layer only on success with logoUrl, add per-layer delete handler, clean up orphans on reset and on save failure. Implement state management (Loading/Success/Error) in Cubit to reflect upload progress.

---

## Design Constraints

**Preflight (ck:cook to verify):**
- Cubit states follow pattern: Initial | Loading | Success | Error | Empty — uploadLogo adds Loading state during POST
- No layer created if upload fails (no orphan logoPath or empty logoUrl layer)
- All UI strings from AppStrings.* (i18n); no hardcoded error text
- Delete operations (both layer-remove and compensating delete on save fail) must be fire-and-forget or have defined error handling (log, do not block save if Cloudinary down)
- ImagePicker is called inside uploadLogo(); if user cancels or picks invalid file, no state change
- handleReset() and handleConfirm() must invoke deleteLogo for all logo layers in draft before clearing/saving

---

## Exact Files and Steps

### Flutter File Paths & Changes

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\presentation\cubit\customizer_cubit.dart`

1. **Add upload state to Cubit** — Add state class `LogoUploadLoading` (or extend existing CustomizerState union). Add state `LogoUploadFailure(String message)` for error. Existing CustomizerState may already have Loading/Error/Success; if so, reuse; if not, add these states. Expose method `uploadAndCreateLogoLayer()` that emits LogoUploadLoading, calls UploadLogoUseCase, and on success emits Success (or Custom state with updated layers), on failure emits LogoUploadFailure.

2. **Expose deleteLogoLayer method in Cubit** — Add method `deleteLogoAndRemoveLayer(String logoUrl, String layerId)` that invokes DeleteLogoUseCase(logoUrl), logs errors (do not throw), and removes layer from state. Fire-and-forget delete; if delete fails on Cloudinary, layer is still removed locally (acceptable per MVP risk).

3. **Add cleanup-on-save in saveDesign method** — Before calling SaveCustomDesignUseCase, iterate all logo layers and invoke DeleteLogoUseCase for each (compensating delete if present). On save failure, do nothing extra (layer already deleted during cleanup). On save success, layers list is cleared.

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\presentation\pages\customizer_actions.dart`

4. **Rewrite uploadLogo() to use upload usecase** — Remove placeholder code that only sets logoPath. After ImagePicker returns file, emit loading state (via Cubit). Call `uploadLogoUsecase.call(UploadLogoParams(file))`. On Result.success(url), emit Success + call Cubit method to create layer with logoUrl (not logoPath). On Result.failure(failure), emit Error + show AppSnackBar with AppStrings.customizerUploadLogoError + do NOT create layer. Add try-catch for ImagePicker exceptions (same error handling).

5. **Add per-layer delete handler** — In layer_editor.dart or customizer_layer_handlers.dart (find where layers are removed), add callback: when user removes a logo layer, call `customizer_cubit.deleteLogoAndRemoveLayer(layer.logoUrl, layer.id)`. Only attempt delete if logoUrl is not null and is a valid http/https URL (skip legacy logo deletion for logoPath-only layers, no-op is safe).

6. **Update handleReset() in customizer_actions.dart** — Before clearing layers, iterate all logo layers; for each with logoUrl, call deleteLogo usecase (fire-and-forget, log errors). Then proceed with existing reset logic (clear layers, reset state).

7. **Update handleConfirm() in customizer_actions.dart** — Before calling SaveCustomDesignUseCase, iterate all logo layers and delete them (compensating delete). If SaveCustomDesignUseCase succeeds, layers are now gone (intended). If SaveCustomDesignUseCase fails, deleted logos are orphaned (MVP limitation — documented in plan.md). Show error to user; do not retry delete.

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\presentation\widgets\` (or existing upload button widget)

8. **Add loading indicator to upload UI** — Find the button/action that triggers uploadLogo() (likely in customizer_page.dart or a modal). Wrap with BlocBuilder<CustomizerCubit, CustomizerState> listening for LogoUploadLoading state. Show CircularProgressIndicator overlay or button.enabled = false during upload. Remove indicator on success or error.

**File:** `d:\GitHub\flutter-ecommerce\lib\core\constants\app_strings.dart` (already updated in Phase 2 with keys; now fill in values)

9. **Define upload/delete error strings** — Ensure these keys exist and have i18n values:
    - `customizerUploadLogoLoading` → "Uploading logo..."
    - `customizerUploadLogoSuccess` → "Logo uploaded successfully."
    - `customizerUploadLogoError` → "Failed to upload logo. Please try again."
    - `customizerDeleteLogoError` → "Failed to delete logo from storage." (optional, mostly logged)
    - `customizerDefaultTextLayer` (existing key, verify present)

10. **Wire Cubit in customizer_page.dart** — Ensure UploadLogoUseCase and DeleteLogoUseCase are injected into CustomizerCubit constructor (or via module). If Cubit is already defined, verify DI in customizer_module.dart includes these usecases (confirmed in Phase 2 Step 15).

---

## Success Criteria

- [ ] uploadLogo() calls UploadLogoUsecase after ImagePicker, shows loading, creates layer with logoUrl on success, shows error snack on failure
- [ ] No layer created if upload fails (verified by checking: layer only added inside Result.success callback, not in try block)
- [ ] Layer removal triggers deleteLogoAndRemoveLayer callback (verify in layer_editor.dart or widget that handles layer removal)
- [ ] handleReset() deletes all logo layers before clearing state
- [ ] handleConfirm() deletes all logo layers before calling SaveDesignUseCase
- [ ] Upload UI shows loading state (CircularProgressIndicator or disabled button) during POST
- [ ] Error messages use AppStrings.* keys (no hardcoded text)
- [ ] CustomizerCubit states compile: `flutter analyze` zero errors
- [ ] Cubit test (if exists) wires UploadLogoUseCase and DeleteLogoUseCase mocks
- [ ] App builds: `flutter build apk --debug` succeeds, no RenderFlex overflow

---

## Quality and Testing State

- **Quality gate:** not evaluated (Cook runs `ck:quality --gate` after implementing this phase)
- **Testing:** not started (ck:test will write Cubit tests mocking usecases; widget tests for loading UI; E2E smoke test for upload flow)
- **Build check:** `flutter analyze lib/features/customizer && flutter build apk --debug` must pass

---

## Spec Coverage

| FR | Phase 3 Deliverable |
|---|---|
| FR-03 | uploadLogo() in customizer_actions.dart: ImagePicker → UploadLogoUsecase → create layer with logoUrl on success |
| FR-04 | Upload failure shows AppStrings error, no layer created with empty/local logoPath |
| FR-07 | deleteLogoAndRemoveLayer per-layer handler; handleReset + handleConfirm cleanup orphans (compensating delete) |
| FR-07 (Orphan MVP limitation) | Known: app kill after upload before save leaves orphan on Cloudinary; acceptable for MVP; future server-side sweep out-of-scope |
| P2 | Loading indicator during upload; error snack on failure; UI remains responsive |

---

## Risks

- **Upload blocks UI:** Dio.post() is async; if not awaited properly, UI hangs. → Mitigated: Cubit handles async; emit Loading before await; emit Success/Error after. UI listens to Cubit state changes via BlocBuilder.
- **Delete orphan race:** User rapidly adds/removes logos; delete call in-flight but layer already removed from state → orphan stays on Cloudinary. → Accepted MVP limitation; documented in plan.md. Future: implement server-side sweep or TTL on orphan files.
- **No error recovery for compensating delete:** If handleConfirm's compensating delete fails, save already attempted or already failed; no retry. → Mitigated: log error, inform user save status (success or fail), do not retry delete. User can manually call delete later if needed (out of scope).
- **User cancels ImagePicker:** upLoadLogo() catches exception, shows error snack. → Verify try-catch does not catch PermissionDeniedException or other OS-level issues that need special UX (might be OK to show generic error).

