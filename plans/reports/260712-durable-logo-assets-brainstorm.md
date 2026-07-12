# Brainstorm: Durable logo assets cho custom design

**Date:** 2026-07-12

## Ideas Explored

- **Upload-on-pick (chọn)** — Trong `uploadLogo()`, ngay khi khách chọn ảnh từ gallery, gọi backend upload → nhận secure URL → lưu vào metadata layer. Đúng ý "upload lúc customize"; đổi lại sinh file rác khi khách bỏ logo giữa chừng → cần orphan cleanup.
- **Batch-upload-on-save (bỏ)** — Gom tất cả logo local, upload một lượt trong `handleConfirm()` cùng preview composite. Ít file rác hơn nhưng phải xử lý multi-file + rollback, và khách chờ lâu hơn lúc lưu.
- **Signed/access-controlled asset URL (bỏ)** — Lệch hoàn toàn convention: cả product/shop/preview đều dùng public Cloudinary secure URL, phân quyền ở tầng API (ownership), không ở tầng asset.
- **Full migration + version field (bỏ)** — Thêm version field vào metadata + migration đánh dấu design cũ. File logo cũ vốn không cứu được nên giá trị thêm rất hạn chế.
- **Read-time interpretation cho logo cũ (chọn)** — Không DB migration; parser/viewer phân biệt URL thật vs local path cũ, logo cũ hiển thị "unavailable" và không rò local path.

## User's Direction

Người dùng xác nhận approach 5 điểm: upload từng logo lên Cloudinary lúc customize qua `IUploadService`; đổi metadata sang `logoUrl`; sửa customizer/API contract/viewer; xử lý upload fail + orphan cleanup + phân quyền; migration tương thích ngược cho logo cũ (unavailable, không bịa).

Sau khi scout code, chốt 2 quyết định gọn scope:
- **Upload timing:** ngay khi khách chọn logo (upload-on-pick).
- **Logo cũ:** chỉ xử lý đọc-thời (hiển thị unavailable), không DB migration.

## Findings từ scout (định hình lại scope)

- Backend đã có `IUploadService.uploadFile/deleteFile/validateFile` trả secure URL — không xây mới.
- `CustomDesignService.saveDesign` đã có sẵn pattern orphan-cleanup (upload ngoài transaction, xóa ảnh khi DB/back-image fail) — tái dùng làm khuôn.
- `designMetadata`/`backDesignMetadata` lưu JSON string opaque ở backend → đổi `logoPath`→`logoUrl` chủ yếu là thay đổi client; backend chỉ cần một endpoint upload file logo lẻ (auth).
- Preview composite (đã nướng logo) đã upload sẵn; chỉ file logo lẻ còn local path.
- **Bug hiện tại:** viewer coi `logoPath` không rỗng = "available" → logo cũ (local path) bị báo nhầm available; `_LayerTile` in nguyên local path ra UI (rò đường dẫn máy khách).
- Không cần version field: sự hiện diện của `logoUrl` (http) vs chỉ có `logoPath` local chính là bộ phân biệt cũ/mới.

## Open Questions

- Endpoint upload logo lẻ: thêm route mới (vd `POST /api/custom-designs/logo`) hay mở rộng flow save? → nghiêng route mới độc lập, trả URL.
- Giới hạn file logo (định dạng/kích thước) dùng chung `validateFile` hiện có hay siết riêng cho logo?
- Có cần xóa logo trên Cloudinary khi khách xóa layer logo trước khi lưu không, hay để cleanup định kỳ gom orphan?

## Risks

- **Orphan tích tụ:** upload-on-pick sinh file không bao giờ được lưu vào design nào (khách chọn rồi bỏ). Cần chiến lược cleanup rõ ràng, không để phình storage.
- **Rò local path cũ:** phải sửa cả `_LayerTile` lẫn `_SelectedLayerDetails` để không hiển thị local path và không báo nhầm "available".
- **Chi phí mạng lúc customize:** mỗi lần chọn logo là một round-trip; cần loading state + xử lý lỗi rõ ràng để không kẹt UI.
