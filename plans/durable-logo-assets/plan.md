# Plan: Durable logo assets cho custom design

## Status

- Mode: Hard
- Source: `plans/durable-logo-assets/spec.md` (Status: Ready, no NEEDS CLARIFICATION)
- Testing: default — Cook chạy compile/analyze/build + `ck:quality --gate` bắt buộc; automated tests giao cho `ck:test` sau.
- Implementation: Phase 1 (backend logo endpoints) quality-approved 2026-07-12. Phase 2 (Flutter data/domain) quality-approved 2026-07-12. Phase 3 (Customizer integration) quality-approved 2026-07-12. Phase 4 not started.

## Scope Challenge

- Exists: partial. Logo hiện chỉ lưu local path (`DesignLayer.logoPath = image.path`); chưa có upload bền vững. Backend đã có `IUploadService` (uploadFile/deleteFile/validateFile) và pattern compensating-delete trong `CustomDesignService.saveDesign`.
- Minimum: 2 endpoint backend (upload/delete logo, tái dùng `IUploadService`) + field `logoUrl` phía client + upload-on-pick trong customizer + delete-on-remove + viewer đọc URL và degrade logo cũ.
- Complexity: Hard — 2 repo (java-ecommerce + flutter-ecommerce), ≥4 tầng, có external storage + orphan cleanup + đọc dữ liệu cũ tương thích ngược.

## Architecture Decisions

1. **Public secure Cloudinary URL**, đúng convention toàn hệ thống (product/shop/preview). KHÔNG signed/expiring URL. Phân quyền ở tầng API (endpoint yêu cầu auth), không ở tầng asset.
2. **Metadata vẫn là JSON string opaque** ở backend (`designMetadata`/`backDesignMetadata`). Không thêm cột schema; `logoUrl` nằm trong JSON. Không DB migration.
3. **Không version field.** Bộ phân biệt cũ/mới chính là: layer mới có `logoUrl` (http/https) vs layer cũ chỉ có `logoPath` (local). Parser đã lenient với field optional nên thêm `logoUrl` là backward-compatible.
4. **Upload-on-pick + delete-on-remove.** Upload ngay khi khách chọn logo; xóa layer logo (hoặc reset) → gọi delete dọn Cloudinary. `handleConfirm` chạy compensating delete nếu save thất bại.
5. **Endpoint upload/delete KHÔNG `@Transactional`** — là external call, theo rule_be #5 (không giữ DB connection khi gọi API ngoài).
6. **Legacy logo degrade an toàn**: viewer coi "available" chỉ khi `logoUrl` là URL http/https; logo cũ (local path) → "unavailable", KHÔNG in local path ra UI, preview composite vẫn hiển thị.

## Delivery Phases

1. [Backend logo endpoints](phase-01-backend-logo-endpoints.md): `POST`/`DELETE /api/custom-designs/logo` tái dùng `IUploadService`, non-transactional, auth.
2. [Flutter data/domain](phase-02-flutter-data-domain.md): field `logoUrl`, datasource/repository/usecase upload+delete logo, DI.
3. [Customizer integration](phase-03-customizer-integration.md): upload-on-pick, delete-on-remove, reset/confirm cleanup, loading/error states.
4. [Viewer read-time](phase-04-viewer-readtime.md): availability theo URL, render network logo, legacy → unavailable, không rò local path.

## Cross-Phase Risks

- **Orphan tích tụ**: upload-on-pick sinh file khi khách chọn rồi bỏ. delete-on-remove + reset-cleanup + compensating-delete phủ phần lớn; các khe hở dưới đây được chấp nhận cho MVP.
- **Known-orphan MVP (accepted, out of scope xử lý tự động):**
  - App bị kill sau khi upload thành công nhưng trước khi save/remove.
  - Mất mạng giữa upload và save → layer đã tạo trên client nhưng design không lưu được.
  - Khách rời customizer không lưu (navigate away) → logo đã upload không gắn design nào.
  - Save một phần rồi timeout: server đã persist metadata chứa URL trước khi client nhận lỗi và chạy compensating delete → có thể lệch (client xóa asset nhưng server giữ URL). Đây là hệ quả cố hữu của upload-on-pick.
  - Mitigation cho tất cả: server-side orphan sweep định kỳ (quét asset trong folder logo không được tham chiếu) — **hardening tương lai, out of scope**. Lần này chỉ best-effort phía client + compensating delete.
- **Bảo mật DELETE (đã xử lý trong Phase 1):** endpoint delete nhận URL từ client → chống IDOR bằng guard folder-scope + validate URL (chỉ cho xóa asset trong folder logo). Rủi ro tồn dư: đoán được public_id ngẫu nhiên của logo chưa lưu người khác — đánh giá THẤP; theo dõi uploader theo user là hardening tương lai.
- **Chưa có per-layer delete handler**: codebase hiện không có nhánh xóa 1 layer; Phase 3 phải dựng nhánh này (hoặc wire vào UI layer removal nếu có) rồi mới gắn delete asset.
- **validateFile limits**: cần xác nhận giới hạn type/size trong `CloudinaryUploadService` để chắc logo thông thường không bị chặn; nếu quá chặt, note lại.
- **Chi phí mạng lúc customize**: mỗi lần chọn logo là 1 round-trip; cần loading state + báo lỗi rõ, không kẹt UI.
- **2-repo coordination**: backend (Phase 1) phải deploy trước hoặc song song để client (Phase 2-3) có endpoint gọi. Cook chỉ author code; thứ tự deploy do operator.

## Global Verification Gates

Mỗi phase phải đạt trước khi phase sau hoàn tất:

1. Backend: `./mvnw -q -o compile` exit 0. Flutter: `dart format` sạch + `flutter analyze` 0 error/warning trên file đụng tới + `flutter build apk --debug` thành công. Đọc trọn output.
2. `ck:quality --gate` không còn blocker/high (và không medium do thay đổi hiện tại sinh ra).
3. `git diff --check` sạch ở repo liên quan; giữ nguyên thay đổi không liên quan.
4. Automated tests thiết kế trong phase để lại cho `ck:test`; đến lúc đó status vẫn "not started", không tự nhận "passed".
5. Success criteria + FR ánh xạ được check tường minh.

## Spec Coverage

- Phase 1: FR-01, FR-07 (delete endpoint), FR-08, FR-09. P1 (durable upload/cleanup backend).
- Phase 2: FR-02, FR-03 (data path), FR-07 (delete path). P1.
- Phase 3: FR-03, FR-04, FR-07 (remove/reset/confirm cleanup). P1 + P2 (loading/retry UX).
- Phase 4: FR-05, FR-06. P1 (admin xem logo mới; logo cũ unavailable an toàn).
- Out of scope (P3): khôi phục logo cũ, version field/DB migration, signed URL, server-side orphan sweep, batch-upload.

## Cook Handoff

Cook theo thứ tự phase. Backend endpoint (Phase 1) nên deploy trước/song song để client có chỗ gọi; Cook chỉ author + static-review, thứ tự deploy do operator. Lệnh đề xuất:

`/ck:cook --hard plans/durable-logo-assets/plan.md`

Testing: Cook KHÔNG chạy test. Chạy `/ck:test` sau khi các phase quality-approved.
