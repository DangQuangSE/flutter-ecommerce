# Phase 1: Backend Logo Endpoints

## Goal

Add two REST endpoints to the backend: one to upload a logo file to Cloudinary and return its secure URL, and one to delete a logo asset by URL. Both endpoints require authentication and reuse the existing upload validation and service layer.

---

## Design Constraints

**Preflight (ck:cook to verify):**
- Backend follows rule_be #5: upload/delete are external calls to Cloudinary, never @Transactional
- Inherited auth: @PreAuthorize("hasRole('USER')") from CustomDesignController class applies to new endpoints
- SecurityUtils.getCurrentUserId() extracts user ID from JWT context
- IUploadService.uploadFile(file, folder) returns secure_url; validateFile(file) checks size/type before upload
- IUploadService.deleteFile(imageUrl) accepts full Cloudinary URL and extracts public_id internally

---

## Exact Files and Steps

### Backend File Paths & Changes

**File:** `d:\GitHub\java-ecommerce\src\main\java\com\sport_pro_be\modules\custom_design\controller\CustomDesignController.java`

1. **Add upload logo endpoint** — Define new `@PostMapping` method `uploadLogo(@RequestPart("file") MultipartFile)`. Call `SecurityUtils.getCurrentUserId()` to get userId (auth). Invoke `IUploadService.validateFile(file)` (validates size/type; throws if invalid). Call `IUploadService.uploadFile(file, CustomDesignMessageConstant.UPLOAD_FOLDER)`. Wrap returned secure URL in `ApiResponse.of(...)` and return 200 OK.

2. **Add delete logo endpoint** — Define new `@DeleteMapping` method `deleteLogo(@RequestParam String url)`. Call `SecurityUtils.getCurrentUserId()` to get userId (for audit/logging, optional). Invoke `IUploadService.deleteFile(url)`. If URL is null/empty, return early (idempotent). Return 200 OK with ApiResponse success message.

**File:** `d:\GitHub\java-ecommerce\src\main\java\com\sport_pro_be\modules\custom_design\constant\CustomDesignMessageConstant.java`

3. **Confirm upload folder constant** — Verify existing `UPLOAD_FOLDER = "custom_designs"` is present. Decide: do logos use same folder or create `LOGO_UPLOAD_FOLDER = "custom_designs/logos"` sibling constant? (Research found existing folder; plan assumes reuse of "custom_designs" for simplicity; if change needed, update both constant and Phase 1 step above.)

4. **Add success messages (optional)** — If needed, add constants for response messages: e.g., `public static final String LOGO_UPLOADED_SUCCESS = "Logo uploaded successfully."; public static final String LOGO_DELETED_SUCCESS = "Logo deleted successfully.";` Use in step 1–2 endpoint responses.

**File:** `d:\GitHub\java-ecommerce\src\main\java\com\sport_pro_be\modules\upload\service\CloudinaryUploadService.java`

5. **Inspect validateFile thresholds** — Confirm MAX_FILE_SIZE (5 MB) and ALLOWED_CONTENT_TYPES (image/jpeg, image/png, image/webp) are suitable for logos. If logo size limits differ, create a new validation method or pass threshold as parameter. (Research: existing limits are 5MB + 3 types; most logos << 5MB; no change expected.)

6. **Confirm deleteFile behavior** — Verify `deleteFile(imageUrl)` accepts full Cloudinary secure_url, calls `extractPublicId()` to parse public_id, and invokes `cloudinary.uploader().destroy()`. Method is idempotent (catches IOException, logs, returns silently; does not throw). Ensure this behavior is stable and used consistently.

---

## Success Criteria

- [ ] CustomDesignController has `@PostMapping("/logo")` endpoint returning 200 + `ApiResponse<String>` (secure URL) on success, 400 on validation error
- [ ] CustomDesignController has `@DeleteMapping("/logo?url=...")` endpoint returning 200 + success message on success
- [ ] Both endpoints inherited `@PreAuthorize("hasRole('USER')")` from class-level annotation
- [ ] `uploadFile()` calls validateFile before upload (no invalid files sent to Cloudinary)
- [ ] `deleteFile()` handles null/empty URLs gracefully (idempotent)
- [ ] Backend compiles: `./mvnw clean compile` returns 0, no warnings
- [ ] Endpoints are callable via curl/Postman: `POST /api/custom-designs/logo` returns JSON response with `data.url` (secure URL)

---

## Quality and Testing State

- **Quality gate:** not evaluated (Cook runs `ck:quality --gate` after implementing this phase)
- **Testing:** not started (ck:test will write integration tests for endpoint contracts; for now, manual Postman verification suffices)
- **Build check:** `./mvnw clean compile` must pass with zero errors

---

## Spec Coverage

| FR | Phase 1 Deliverable |
|---|---|
| FR-01 | POST /api/custom-designs/logo endpoint: accepts multipart file, validates via validateFile, uploads via IUploadService.uploadFile, returns secure URL in ApiResponse |
| FR-08 | Endpoint requires JWT auth (@PreAuthorize); returns public secure Cloudinary URL (no signed/expiring URL innovation) |
| FR-07 | DELETE /api/custom-designs/logo endpoint to enable orphan cleanup; accepts full URL, calls IUploadService.deleteFile |
| FR-09 | No schema/database changes; endpoints only handle file upload/delete, not metadata storage |

---

## Risks

- **Endpoint naming collision:** /api/custom-designs/logo conflicts with existing saveDesign? → Reviewed controller; saveDesign uses `@PostMapping("")` (empty path) + multipart; logo endpoint uses distinct `@PostMapping("/logo")` — no collision.
- **Auth propagation:** SecurityUtils.getCurrentUserId() may fail if JWT not in context. → Mitigated by @PreAuthorize at class level; request is blocked before endpoint logic runs.
- **Cloudinary quota:** repeated uploads may exceed account limits. → Noted for monitoring; no code mitigation; Phase 3 handles orphan cleanup to minimize waste.

