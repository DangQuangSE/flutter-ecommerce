# Phase 3: Customizer integration

## Goal

Kết nối flow thật: upload logo ngay khi khách chọn (chỉ tạo layer khi có `logoUrl`), và dọn Cloudinary khi khách xóa logo / reset / khi save thất bại — với loading/error state rõ ràng.

## Design Constraints

- Repo: `d:\GitHub\flutter-ecommerce`, chủ yếu `lib/features/customizer/presentation/pages/customizer_actions.dart` (+ nơi xóa/hiển thị layer).
- Mọi chuỗi hiển thị mới là `AppStrings.*` (i18n — CLAUDE.md).
- Upload-on-pick: chỉ commit layer khi upload thành công; upload fail → KHÔNG tạo layer, không lưu local path, báo lỗi AppStrings.
- delete-on-remove: mọi nhánh làm biến mất một logo layer phải cố gọi `deleteLogo(url)`.
- Không coupling cubit lẫn nhau ngoài mức cần thiết; giữ trạng thái ở `CustomizerCubit`/page state theo mẫu hiện có.
- Preflight (BẮT BUỘC, ghi kết quả vào Design Constraints trước khi code): (a) đọc `customizer_actions.dart`, `customizer_layer_handlers.dart`, `layer_editor.dart`, `layer_overlay_stack.dart` để xác định **có sẵn nhánh xóa 1 layer hay chưa** — research cho thấy KHÔNG có handler `deleteLayer/removeLayer`; nếu đúng vậy, Step 2 phải DỰNG handler này, không chỉ "wire". (b) đọc `customizer_cubit.dart`/`customizer_state.dart` + page state để chốt chỗ giữ cờ `isUploadingLogo`. (c) `grep` `app_strings.dart` xác nhận/thêm các hằng cần dùng (`customizerUploadImageError` và chuỗi loading/lỗi mới nếu thiếu).

## Exact Files and Steps

1. `uploadLogo()` (customizer_actions.dart:47): sau `ImagePicker.pickImage`, bật loading; gọi `UploadLogoUseCase` với file; `Result`:
   - Success → tạo `DesignLayer(type: logo, logoUrl: url, ...)` (KHÔNG set logoPath), thêm vào layers, set active; tắt loading.
   - Failure → không tạo layer, tắt loading, `AppSnackBar` với `AppStrings.customizerUploadImageError` (hoặc chuỗi mới rõ nghĩa "upload thất bại").
2. **Per-layer delete**: theo preflight, nếu chưa có handler xóa layer thì DỰNG mới (vd `removeLayer(DesignLayer)` trong `customizer_layer_handlers.dart` + nút xóa trong `layer_editor.dart`/`layer_overlay_stack.dart` theo UI hiện có). Khi layer bị xóa là logo và có `logoUrl` (remote) → gọi `DeleteLogoUseCase(url)` **best-effort** (lỗi delete chỉ log, KHÔNG chặn việc xóa layer khỏi UI, tránh kẹt). Ghi rõ best-effort trong code comment.
3. `handleReset()` (customizer_actions.dart:76): trước khi `layers.clear()`, gom mọi logo layer có `logoUrl` và gọi `DeleteLogoUseCase` cho từng cái (best-effort) rồi mới clear.
4. `handleConfirm()` (customizer_actions.dart:167): nếu `saveCustomization` trả trạng thái lỗi, chạy compensating delete cho các logo `logoUrl` vừa gắn (best-effort) để không mồ côi; giữ nguyên các bước capture/preview hiện có.
5. Loading state cho upload logo (P2), cụ thể: (a) giữ cờ `isUploadingLogo` ở chỗ đã chốt trong preflight (page `State` hoặc `CustomizerCubit` state — theo mẫu hiện có, KHÔNG tạo cubit mới); (b) trong lúc upload: nút "thêm logo" bị disable và hiển thị spinner (thay icon `cloud_upload` bằng `CircularProgressIndicator` nhỏ, hoặc overlay); (c) khi lỗi: bật lại nút, cho chọn/thử lại; test xác nhận nút disabled suốt lúc upload và enabled lại sau success/fail.
6. Ghi chú known-orphan MVP (app bị kill sau upload trước save/remove) là hạn chế chấp nhận; server-side sweep out of scope.

## Tests Planned for Later `ck:test`

- uploadLogo thành công → tạo đúng 1 layer có `logoUrl`, không có `logoPath`; thất bại → 0 layer, hiện lỗi.
- Xóa logo layer → gọi `deleteLogo(url)` đúng một lần với URL đúng.
- handleReset với N logo layer → gọi delete N lần trước khi clear.
- handleConfirm save-fail → compensating delete cho logo vừa upload.
- Loading state bật/tắt đúng; delete lỗi không kẹt UI (best-effort).

## Build and Quality Gate

- `dart format` sạch; `flutter analyze` 0 error/warning; `flutter build apk --debug` thành công. Đọc trọn output.
- `ck:quality --gate`: không blocker/high; kiểm riêng: không rò local path, không tạo layer khi upload fail, mọi nhánh xóa có delete.
- `git diff --check` sạch.

## Success Criteria

- 100% logo thêm mới có `logoUrl`; 0 layer tạo ra khi upload fail.
- Mọi nhánh xóa/reset/save-fail đều kích hoạt delete asset (best-effort), trừ known-orphan đã ghi nhận.
- Loading/error rõ ràng, không kẹt UI.

## Spec Coverage

- FR-03 (upload-on-pick commit), FR-04 (loading/error, không orphan/không local path), FR-07 (remove/reset/confirm cleanup). P2: loading/retry UX.

## Quality and Testing State

- Quality: `ck:quality --gate` approved 2026-07-12 (report + receipt: `quality/phase-03-customizer-integration-quality-report.json`/`-receipt.json`). 1 NOTED (pre-existing CRLF blob encoding, same class as Phase 2) — không block. Critical invariant (newlyUploadedLogoUrls chỉ track logo upload trong session này, không bao giờ đụng logo đã lưu) verified độc lập.
- Testing: not started; cases trên để cho `ck:test`.
- Analyze/build gate: `dart format` sạch, `flutter analyze` 0 error/warning, `flutter build apk --debug` thành công, `git diff --check` sạch trên 8/9 file.
- Ngoài phạm vi liệt kê ban đầu nhưng bắt buộc để tính năng chạy đúng: cập nhật `layer_overlay_stack.dart` (canvas) để render `logoUrl` qua `CachedNetworkImage`; sửa `customizerUploadLogoHint` (PNG/JPG/SVG → PNG/JPG/WEBP, khớp giới hạn backend thật); đổi `CustomizerCubit.saveCustomization` trả `Result<int>` để `handleConfirm` biết chính xác thành/bại phục vụ compensating delete.
