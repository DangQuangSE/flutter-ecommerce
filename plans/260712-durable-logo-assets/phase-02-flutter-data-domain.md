# Phase 2: Flutter Data & Domain Layer

## Goal

Add `logoUrl` field to the data model, update serialization to preserve both new and legacy logo references, implement datasource methods to call backend upload/delete endpoints, build repository and usecase layers using Result<T> for error handling, and register all dependencies in the DI container.

---

## Design Constraints

**Preflight (ck:cook to verify):**
- Error handling must use Result<T> or Either<Failure, T> — never raw throws across layer boundaries
- Models (toJson/fromJson) live in data/models only; domain entities remain pure Dart (no Flutter imports)
- DI registration in customizer_module.dart only; no locator<T>() calls inside widgets
- DesignLayer parser (design_metadata_parser.dart) is lenient on optional fields; adding logoUrl does not require migration or versioning
- Datasource methods follow existing pattern: wrap DioException in NetworkException or handle gracefully
- CachedNetworkImage is used for all network image rendering in presentation layer (Phase 4), but not in data/domain

---

## Exact Files and Steps

### Flutter File Paths & Changes

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\presentation\models\design_layer.dart`

1. **Add logoUrl to DesignLayer model** — Add field `final String? logoUrl;` after `logoPath`. Update constructor to accept optional `logoUrl` parameter. Update `copyWith()` method to include `logoUrl`. Update `toJson()` to serialize `logoUrl` (new designs write logoUrl, not logoPath). Update `fromJson()` factory to deserialize `logoUrl` as optional String; maintain lenient fallback to null if missing (backward-compatible for old metadata).

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\data\datasources\custom_design_remote_datasource.dart` (abstract interface)

2. **Define datasource upload method** — Add abstract method `Future<String> uploadLogo(File file)` that returns the secure URL. No error handling in interface; exceptions thrown by implementation.

3. **Define datasource delete method** — Add abstract method `Future<void> deleteLogo(String logoUrl)` to delete a logo by URL. Idempotent; no return value.

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\data\datasources\custom_design_remote_datasource_impl.dart`

4. **Implement uploadLogo** — Wrap file in MultipartFile using http_parser.MediaType (follow saveDesign pattern: `MultipartFile.fromBytes` for image bytes, or `MultipartFile.fromPath` for File object with image/png contentType). Build FormData with single "file" key. Call `_dioClient.dio.post(ApiConstants.customDesigns + "/logo", data: formData)`. Parse response to extract `data.url` (backend returns ApiResponse<String> with secure URL). Return URL string. Catch DioException → throw NetworkException(message, statusCode).

5. **Implement deleteLogo** — Call `_dioClient.dio.delete(ApiConstants.customDesigns + "/logo", queryParameters: {"url": logoUrl})`. Expect 200 response (idempotent). Do not parse data. Catch DioException → throw NetworkException.

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\domain\repositories\custom_design_repository.dart` (abstract interface)

6. **Add repository upload method** — Add abstract method `Future<Result<String>> uploadLogoFile(File file)` returning Result<String> (the URL). Wraps datasource in error handling.

7. **Add repository delete method** — Add abstract method `Future<Result<void>> deleteLogoFile(String logoUrl)` returning Result<void>.

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\data\repositories\custom_design_repository_impl.dart`

8. **Implement uploadLogoFile** — Call datasource.uploadLogo(file) inside try-catch. On success, return `Result.success(url)`. On NetworkException, map to Failure subclass (e.g., `LogoUploadFailure(message)`) and return `Result.failure(failure)`.

9. **Implement deleteLogoFile** — Call datasource.deleteLogo(logoUrl) inside try-catch. Return `Result.success(null)` on success. On NetworkException, return `Result.failure(LogoDeleteFailure(message))`.

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\domain\usecases\` (new or extend existing)

10. **Create upload usecase** — File `upload_logo_usecase.dart`: public class `UploadLogoUseCase extends UseCase<String, UploadLogoParams>` (or use existing usecase pattern if different). Call `repository.uploadLogoFile(params.file)`. Return Result mapped (success → URL, failure → Failure). Constructor accepts `ICustomDesignRepository`.

11. **Create delete usecase** — File `delete_logo_usecase.dart`: public class `DeleteLogoUseCase extends UseCase<void, DeleteLogoParams>`. Call `repository.deleteLogoFile(params.logoUrl)`. Return Result. Constructor accepts `ICustomDesignRepository`.

12. **Create params classes** (if needed) — `UploadLogoParams(File file)`, `DeleteLogoParams(String logoUrl)` to wrap parameters in usecase call.

**File:** `d:\GitHub\flutter-ecommerce\lib\features\customizer\app\di\customizer_module.dart` (or similar DI config for feature)

13. **Register datasource** — Add to module: `getIt.singleton<CustomDesignRemoteDataSource>(CustomDesignRemoteDataSourceImpl(getIt<DioClient>()))`  (or wrap existing registration if already present).

14. **Register repository** — Add: `getIt.singleton<ICustomDesignRepository>(CustomDesignRepositoryImpl(getIt<CustomDesignRemoteDataSource>()))`  (or update existing if partial implementation).

15. **Register usecases** — Add: `getIt.singleton<UploadLogoUseCase>(UploadLogoUseCase(getIt<ICustomDesignRepository>()))` and `getIt.singleton<DeleteLogoUseCase>(DeleteLogoUseCase(getIt<ICustomDesignRepository>()))`.

**File:** `d:\GitHub\flutter-ecommerce\lib\core\constants\app_strings.dart`

16. **Add i18n strings (new keys for Phase 3 UI)** — Add placeholder strings for error messages and loading text; examples:
    - `customizerUploadLogoLoading`
    - `customizerUploadLogoSuccess`
    - `customizerUploadLogoError`
    - `customizerDeleteLogoError`
    - `designViewerAssetAvailable` (for viewer Phase 4)
    - `designViewerAssetUnavailable` (for viewer Phase 4)
    Actual text values filled in by translator/product; for now, use English placeholder text.

---

## Success Criteria

- [ ] DesignLayer has `logoUrl` field (String?), toJson/fromJson serialize it, copyWith includes it
- [ ] design_metadata_parser.dart continues to parse layers without logoUrl (backward-compat test by examining code)
- [ ] custom_design_remote_datasource_impl.dart has uploadLogo(File) → calls POST /api/custom-designs/logo, returns URL
- [ ] custom_design_remote_datasource_impl.dart has deleteLogo(String) → calls DELETE /api/custom-designs/logo?url=...
- [ ] custom_design_repository_impl.dart wraps datasource calls in Result<T>, maps exceptions to Failure
- [ ] UploadLogoUseCase and DeleteLogoUseCase classes exist, accept params, return Result
- [ ] customizer_module.dart registers all three (datasource, repository, both usecases) in GetIt
- [ ] AppStrings has keys for upload/delete error messages and viewer asset status
- [ ] `flutter analyze` reports zero errors on modified files
- [ ] `dart format` requires no changes on modified files

---

## Quality and Testing State

- **Quality gate:** not evaluated (Cook runs `ck:quality --gate` after implementing this phase)
- **Testing:** not started (ck:test will write unit tests for serialization, Result mapping, usecase contracts; now just code structure)
- **Lint/format:** `dart analyze lib/features/customizer && dart format lib/features/customizer` must pass

---

## Spec Coverage

| FR | Phase 2 Deliverable |
|---|---|
| FR-02 | DesignLayer adds nullable logoUrl; toJson/fromJson preserve both logoUrl (new) and logoPath (legacy read-only) |
| FR-09 | No database changes; logoUrl stored inside designMetadata JSON string via toJson |
| FR-03 (partial) | Datasource methods ready; integration in Phase 3 |
| FR-07 (partial) | deleteLogo datasource ready; integration in Phase 3 |

---

## Risks

- **Serialization backward-compat:** Old metadata has logoPath but no logoUrl. Parser must handle missing logoUrl gracefully. → Mitigated: DesignLayer.fromJson() deserializes logoUrl as optional with null default; parser is already lenient in design_metadata_parser.dart (only strict on required fields: id, type, view, color, fontSize, x, y).
- **DI registration order:** If repository depends on datasource but datasource not yet registered, factory fails. → Mitigated: Step 13–15 order registration bottom-up (datasource, then repository, then usecases); verify no circular dependencies.
- **API endpoint changes between Phase 1 and Phase 2:** Frontend may implement against outdated backend contract. → Mitigated: Phase 1 completes first; Phase 2 endpoints are stable per Phase 1 success criteria.

