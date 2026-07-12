# Spec: Durable logo assets cho custom design

**Date:** 2026-07-12
**Status:** Ready

---

## Problem Statement

Layer logo trong custom design hiện chỉ lưu **đường dẫn file cục bộ** trên máy khách (`DesignLayer.logoPath = image.path`), nên admin (và cả chính khách trên thiết bị khác) không xem/tải lại được từng logo gốc — file không tồn tại ngoài thiết bị đã tạo. Cần lưu logo lên storage bền vững (Cloudinary) và tham chiếu bằng URL để logo gốc truy cập được ở mọi nơi, trong khi logo cũ (file đã mất) degrade an toàn.

---

## User Stories

- **[P1]** Là khách customize sản phẩm, khi tôi thêm một logo vào canvas, hệ thống upload logo đó lên storage bền vững và lưu URL vào thiết kế, để logo gốc không phụ thuộc thiết bị của tôi.
  Accepted when: sau khi chọn logo thành công, metadata layer chứa một `logoUrl` là secure URL Cloudinary hợp lệ (http/https), không còn là local path.

- **[P1]** Là admin xem thiết kế đơn hàng, tôi muốn thấy từng logo gốc của thiết kế mới, để kiểm tra chi tiết thành phần in.
  Accepted when: trong design viewer, layer logo có `logoUrl` hiển thị được ảnh logo (network image) và trạng thái "available".

- **[P1]** Là admin xem thiết kế **cũ** (chỉ có local path), tôi muốn app không crash và không hiển thị thông tin gây hiểu nhầm.
  Accepted when: layer logo cũ (không có `logoUrl` là URL) hiển thị trạng thái "unavailable", KHÔNG in local path ra UI, và preview composite vẫn hiển thị bình thường.

- **[P1]** Là hệ thống, khi upload logo thất bại hoặc khách bỏ logo, tôi không để lại file rác vô hạn trên Cloudinary.
  Accepted when: upload fail được báo lỗi rõ ràng và không ghi URL vào metadata; có cơ chế xử lý orphan (xem FR-07).

- **[P2]** Là khách, khi upload logo đang chạy, tôi thấy trạng thái loading và có thể thử lại nếu lỗi.
  Accepted when: nút/thao tác thêm logo có loading indicator trong lúc upload và thông báo lỗi (AppStrings) khi thất bại, không kẹt UI.

- **[P3]** _(out of scope — khôi phục logo cũ đã mất file local; version field trong metadata; migration mutate dữ liệu cũ; signed/expiring asset URL)_

---

## Functional Requirements

1. FR-01: Backend cung cấp endpoint upload một file logo lẻ (vd `POST /api/custom-designs/logo`), yêu cầu xác thực (authenticated customer), nhận `multipart/form-data` file, `validateFile` (định dạng/kích thước theo convention hiện có), upload qua `IUploadService.uploadFile(file, <logo folder>)`, trả về secure URL.
2. FR-02: `DesignLayer` thêm field `logoUrl` (String?, http/https). `toJson`/`fromJson` serialize `logoUrl`; giữ nguyên `logoPath` để đọc dữ liệu cũ (không ghi mới).
3. FR-03: Trong `uploadLogo()` (customizer_actions.dart), sau khi `ImagePicker` trả file, client gọi endpoint FR-01, nhận URL, tạo layer logo với `logoUrl = <secure URL>` (không lưu local path vào metadata mới).
4. FR-04: Upload logo chạy với loading state; khi thất bại → hiển thị lỗi qua `AppStrings` (i18n), KHÔNG tạo layer với URL rỗng/local path.
5. FR-05: Design viewer xác định "logo available" khi và chỉ khi `logoUrl` là URL http/https không rỗng; render ảnh logo bằng `CachedNetworkImage` với error/placeholder widget.
6. FR-06: Logo cũ (chỉ có `logoPath` local, hoặc `logoUrl` không phải URL) → viewer hiển thị "unavailable"; `_LayerTile` và `_SelectedLayerDetails` KHÔNG in local path ra UI (dùng chuỗi AppStrings trung tính).
7. FR-07: Orphan handling — khi khách **xóa một layer logo** (trước khi lưu hoặc trong lúc edit), client gọi endpoint delete (vd `DELETE /api/custom-designs/logo?url=...`) để backend `IUploadService.deleteFile(url)` dọn file trên Cloudinary. Ngoài ra, upload fail hoặc save-design fail cũng không được để URL mồ côi (theo pattern compensating của `CustomDesignService.saveDesign`).
8. FR-08: Endpoint upload logo dùng public secure Cloudinary URL đúng convention hệ thống (giống product/shop/preview); KHÔNG phát minh signed URL. Phân quyền ở tầng API: chỉ user đã đăng nhập mới upload được.
9. FR-09: Backend tiếp tục lưu `designMetadata`/`backDesignMetadata` dạng JSON string opaque; không thêm cột schema cho logo URL (URL nằm trong JSON metadata).

---

## Non-Functional Requirements

- Performance: mỗi thao tác thêm logo tối đa 1 round-trip upload; không upload lại logo đã có URL.
- Security: endpoint upload yêu cầu JWT hợp lệ; `validateFile` chặn định dạng/kích thước ngoài giới hạn trước khi gọi Cloudinary.
- Availability/Robustness: metadata cũ hoặc URL hỏng không được gây crash viewer; luôn degrade về "unavailable" + preview-only.
- i18n: mọi chuỗi hiển thị mới đều là `AppStrings.*` (theo grading standards).

---

## Success Criteria

- [ ] 100% logo thêm mới sau deploy có `logoUrl` là secure URL Cloudinary trong metadata (kiểm bằng test + kiểm tra 1 design thật).
- [ ] Design viewer hiển thị ảnh logo cho design mới, và "unavailable" (không rò local path) cho design cũ — 0 crash trên metadata cũ/malformed trong automated test.
- [ ] Upload logo thất bại → 0 layer được tạo với URL rỗng/local path; lỗi báo qua AppStrings.
- [ ] 0 file logo mồ côi khi save-design fail (compensating delete chạy đúng, xác nhận bằng test).
- [ ] `flutter analyze` + `dart format` sạch trên file đụng tới; backend compile + `ck:quality --gate` không blocker/high.

---

## Out of Scope

- Khôi phục logo cũ đã mất file local (không thể — file chỉ tồn tại trên thiết bị gốc).
- Version field trong metadata / migration mutate dữ liệu design cũ.
- Signed / expiring / access-controlled asset URL (lệch convention hiện tại).
- Chỉnh sửa/tái sắp xếp layer từ order detail; thay đổi công thức tính giá in.
- Batch-upload logo lúc save (đã chọn upload-on-pick).

---

## Assumptions

- Cloudinary + `IUploadService` hiện có đủ dùng cho logo; chỉ cần thêm folder/endpoint, không đổi provider.
- Ảnh logo là public URL chấp nhận được về mặt riêng tư (giống toàn bộ ảnh khác trong hệ thống).
- Backend đối xử metadata như JSON string opaque; thay đổi format logo không phá schema.
- Frontend customizer là nơi tạo logo; các client khác không ghi metadata custom design.

---

## Decisions Resolved

- Orphan cleanup: **delete-on-remove** — khách xóa layer logo → client gọi endpoint delete → backend `deleteFile(url)` dọn ngay trên Cloudinary. (Đã chốt 2026-07-12.)
- Upload timing: **upload-on-pick** (ngay khi chọn logo).
- Logo cũ: **read-time only**, hiển thị unavailable, không DB migration.
- Asset URL: **public secure Cloudinary URL** theo convention hệ thống.
