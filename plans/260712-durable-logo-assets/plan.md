# Plan: Durable Logo Assets for Custom Design

**Status:** 🟡 In Progress  
**Date:** 2026-07-12  
**Mode:** Hard  
**Scope:** Backend + Flutter | Two-repo delivery  

---

## Overview

This plan delivers persistent, cloud-backed logo storage for custom product designs. Logos will be uploaded to Cloudinary on selection (upload-on-pick), metadata will reference secure URLs instead of ephemeral local paths, and the design viewer will gracefully degrade when showing legacy designs. This eliminates orphan logos and enables design re-access from any device.

---

## Scope Challenge & Architecture Decisions

### Scope Challenge: Orphan & Legacy Coexistence
- **Upload-on-pick** creates transient assets if the customer aborts before saving → requires per-layer delete handler during edit and compensating delete on save failure.
- **Legacy designs** with only `logoPath` (local file) must display without crash, without exposing local paths in UI, and without false "available" status.
- **No schema migration** — metadata is JSON-opaque; logo URL lives inside the JSON, no new columns.

### Architecture Decisions (Locked)

1. **Upload Timing:** Upload logo on pick, immediately after `ImagePicker.pickImage()`. No batch-on-save; immediate feedback.
2. **Delete Strategy:** Client calls delete endpoint when customer removes a layer logo, OR when layer-add fails, OR when save fails (compensating delete). Server drops file from Cloudinary immediately.
3. **Metadata Transition:** Add nullable `logoUrl` (String?) to `DesignLayer`. Keep `logoPath` read-only for legacy metadata. Parser is already lenient on optional fields (confirmed in design_metadata_parser.dart); adding logoUrl is backward-compatible.
4. **Legacy Visibility:** Read-time check: if `logoUrl` is a valid http/https URL, show "available" + render via `CachedNetworkImage`; else show "unavailable" + hide local path in UI (use `AppStrings` neutral text).
5. **Endpoint Design:** Reuse existing `IUploadService.uploadFile/deleteFile/validateFile` and `CustomDesignMessageConstant.UPLOAD_FOLDER = "custom_designs"`. Decide whether logos use same folder or sibling constant (noted in Phase 1).
6. **Error Handling:** Use `Result<T>` in Flutter data layer; show `AppStrings` localized errors in UI; never create orphan layers (no layer with empty/local logoPath committed on failure).
7. **Known Limitation (MVP):** If app is killed after upload but before save, the logo file remains on Cloudinary (orphan). Noted for future hardening; server-side sweep out-of-scope.

---

## Delivery Phases

- [ ] **Phase 1:** Backend Logo Endpoints — POST/DELETE endpoints, no @Transactional, validateFile, secure URL return
- [ ] **Phase 2:** Flutter Data & Domain Layer — logoUrl in DesignLayer, datasource/repo/usecase, DI registration
- [ ] **Phase 3:** Customizer UI Integration — upload-on-pick + loading, delete-on-remove, reset/confirm cleanup
- [ ] **Phase 4:** Viewer Read-Time & Legacy Handling — availability detection, logo render, hide old paths

---

## Cross-Phase Risks

| Severity | Risk | Mitigation |
|---|---|---|
| **HIGH** | Orphan accumulation (upload-on-pick + abort) | Phase 3 must add layer-delete handler and compensating delete on save failure; Phase 1 deleteFile must work reliably. Test orphan cleanup in ck:test. |
| **HIGH** | Legacy logo crash or path leak | Phase 4 must strict-validate logoUrl format before render; _LayerTile and _SelectedLayerDetails must never print logoPath; parser already lenient, toJson/fromJson preserve logoPath for read-only access. |
| **MEDIUM** | Upload blocks UI / no feedback | Phase 3 adds loading state during upload; on error, show AppStrings message; do not kẹt state. Ensure UI remains responsive. |
| **MEDIUM** | Endpoint auth leak | Phase 1 confirms @PreAuthorize("hasRole('USER')") inherited from controller class, SecurityUtils.getCurrentUserId() in endpoint. Verify JWT attached in Phase 1 review. |
| **LOW** | Concurrent edit: two instances edit same design concurrently → delete orphan race | Out of scope MVP; optimistic locking on design save is separate feature. Document as known limitation. |

---

## Global Verification Gates

### Build & Compile Gates (after each phase)

**Backend (Phase 1):**
```bash
cd d:\GitHub\java-ecommerce
./mvnw clean compile
# Zero compiler errors; no @Transactional violation warnings
```

**Flutter (Phases 2–4):**
```bash
cd d:\GitHub\flutter-ecommerce
dart format --set-exit-if-changed lib/features/customizer/
flutter analyze --no-pub lib/features/customizer/
flutter build apk --debug
# Zero format issues, zero analyze errors, apk builds successfully
```

### Quality Gate

After Phase 4 complete, run:
```bash
cd d:\GitHub\flutter-ecommerce
flutter analyze
dart format .
# Plus ck:quality --gate (run by Cook post-implementation)
```

### Git Diff Check

```bash
git diff --check
# No trailing whitespace, no line-ending issues
```

### Code Review Checklist (ck:quality inline)

- ✓ Result<T> / Either<Failure, T> used for error; no raw throw across layers
- ✓ All new UI strings in AppStrings.* (i18n)
- ✓ Models toJson/fromJson in data/models only
- ✓ DI registration in customizer_module.dart, no locator<T>() in widgets
- ✓ CachedNetworkImage for network images; error widget provided
- ✓ State pattern: Loading, Success, Error states in Cubit
- ✓ No RenderFlex overflow in preview/viewer

---

## Spec Coverage Matrix

| Spec Item | Phase | File / Notes |
|---|---|---|
| **P1: Upload logoUrl on select** | 3 | customizer_actions.dart; uploadLogo() calls usecase, awaits URL, creates layer with logoUrl |
| **FR-01: Backend upload endpoint** | 1 | CustomDesignController; POST /api/custom-designs/logo |
| **FR-02: logoUrl in DesignLayer** | 2 | design_layer.dart; add String? logoUrl; toJson/fromJson |
| **FR-03: uploadLogo() integration** | 3 | customizer_actions.dart; ImagePicker → usecase → layer with logoUrl |
| **FR-04: Upload failure → no layer** | 3 | customizer_actions.dart; on error show AppStrings, do not create layer |
| **FR-05: Viewer shows logoUrl if valid** | 4 | design_viewer_page.dart; _Preview + _LayerTile check http/https → CachedNetworkImage |
| **FR-06: Legacy logo unavailable + no path leak** | 4 | design_viewer_page.dart; _SelectedLayerDetails + _LayerTile hide logoPath, use AppStrings |
| **FR-07: Delete orphans on remove/reset/fail** | 3 | customizer_actions.dart; per-layer delete handler, handleReset(), handleConfirm() compensate |
| **FR-08: Public secure URL + auth** | 1 | CustomDesignController; @PreAuthorize, endpoint returns Cloudinary secure_url |
| **FR-09: No schema change** | 2 | logoUrl lives in designMetadata JSON string; no new DB columns |
| **P2: Loading + error UX** | 3 | customizer_actions.dart; show loading during upload, error snack on fail |
| **P3: Out of Scope** | — | Signed URLs, version field, migration, batch-upload |

---

## Testing Strategy

**Mode:** Default (no --tdd); Cook runs compile/analyze/build + ck:quality gate; automated tests deferred to ck:test.

### Phases 1–4: Quality & Build Verification Only
- Phase 1: Backend compiles, analyze finds no errors, endpoints callable via Postman/curl
- Phase 2: Flutter analyze + format pass, no unused imports
- Phase 3: App builds apk --debug, no RenderFlex overflow, Cubit states wired correctly
- Phase 4: App builds, design viewer renders without crash on legacy/malformed metadata

### Post-Implementation (ck:test)
- Unit tests: DesignLayer serialization with/without logoUrl
- Unit tests: DesignMetadataParser lenient on logoUrl presence/absence
- Integration tests: uploadLogo usecase calls datasource, handles NetworkException
- Integration tests: deleteLogo usecase, Cloudinary delete
- Widget tests: _LayerTile and _SelectedLayerDetails do not expose logoPath
- Widget tests: _Preview renders CachedNetworkImage for valid URL, icon for invalid/missing
- E2E (smoke): customizer upload logo → save design → viewer displays → admin views logo (if on newer design)

---

## Cook Handoff

Once plan is approved and phases are implemented, Cook will run:

```bash
# Quality gate (automated + manual review)
ck:quality --gate

# Deferred to ck:test
ck:test
```

Expected outcome:
- Zero blocker/high quality issues
- Logo uploads, saves, and displays in viewer
- Legacy designs do not crash
- No local paths exposed in UI

---

## References

- **Spec:** d:\GitHub\flutter-ecommerce\plans\durable-logo-assets\spec.md (Status: Ready)
- **Brainstorm:** d:\GitHub\flutter-ecommerce\plans\reports\260712-durable-logo-assets-brainstorm.md
- **Backend Module:** d:\GitHub\java-ecommerce\src\main\java\com\sport_pro_be\modules\custom_design
- **Upload Service:** d:\GitHub\java-ecommerce\src\main\java\com\sport_pro_be\modules\upload\service\CloudinaryUploadService.java
- **Flutter Feature:** d:\GitHub\flutter-ecommerce\lib\features\customizer
- **Flutter Grading:** @.claude/rules/flutter-grading-standards.md

