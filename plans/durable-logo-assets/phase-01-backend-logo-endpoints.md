# Phase 1: Backend logo endpoints

## Goal

Cung cấp hai endpoint để client upload một file logo lẻ lên Cloudinary (nhận secure URL) và xóa một logo khỏi Cloudinary khi khách bỏ nó, tái dùng `IUploadService` sẵn có, không đụng schema.

## Design Constraints

- Repo: `d:\GitHub\java-ecommerce`.
- Tái dùng `IUploadService.uploadFile/deleteFile/validateFile`; KHÔNG viết wrapper Cloudinary mới.
- Endpoint KHÔNG `@Transactional` (external call — rule_be #5: không giữ DB connection khi gọi API ngoài). `validateFile` chạy TRƯỚC `uploadFile`.
- `deleteFile(imageUrl)` nhận full Cloudinary URL (không cần public_id) — client truyền lại `logoUrl` đã lưu.
- Auth theo đúng convention của `CustomDesignController` hiện tại (class-level `@PreAuthorize` / `SecurityUtils.getCurrentUserId()` — dùng đúng dạng đang có, xác nhận khi implement).
- Response bọc trong `ApiResponse<...>` đúng convention module.
- Preflight (xác nhận 2026-07-12): `CustomDesignController` dùng class-level `@PreAuthorize("hasRole('USER')")` + `@RequiredArgsConstructor`; userId qua `SecurityUtils.getCurrentUserId()`; response `ResponseEntity<ApiResponse<T>>` qua `ApiResponse.of(message, data)`. `CloudinaryUploadService.validateFile`: max 5MB, chỉ `image/jpeg|png|webp` — đủ cho logo thông thường, không cần điều chỉnh. `deleteFile(url)` tự tách `publicId` bằng cách split `"/upload/"`, null/empty-safe, nuốt `IOException` (chỉ log) — **không tự giới hạn folder**, guard IDOR phải thêm ở service trước khi gọi. Exception dùng `BadRequestException(message)` (extends `AppException`, status 400) cho các guard reject. `CustomDesignMessageConstant.UPLOAD_FOLDER = "custom_designs"` (ảnh preview/design) — logo dùng hằng riêng `LOGO_UPLOAD_FOLDER = "custom_design_logos"` để guard folder-scope phân biệt được.

## Exact Files and Steps

1. `CustomDesignController.java`: thêm
   - `POST /api/custom-designs/logo` — nhận `@RequestPart("file") MultipartFile file`; gọi `validateFile(file)` rồi `uploadFile(file, <folder>)`; trả secure URL trong `ApiResponse`. Ủy quyền cho service (không nhét logic upload vào controller nếu convention module đặt ở service — theo mẫu `saveDesign`).
   - `DELETE /api/custom-designs/logo` — nhận `@RequestParam("url") String url`; gọi service `deleteLogo(url)` (đã có guard IDOR ở bước 2); trả `ApiResponse` rỗng/thành công. Auth = convention controller.
2. `ICustomDesignService.java` + `CustomDesignService.java`: thêm method `uploadLogo(MultipartFile) : String` và `deleteLogo(String url) : void`, đặt cạnh `saveDesign`. Không `@Transactional`. `uploadLogo` = validate + upload + return URL; `deleteLogo` = **guard bảo mật** rồi `deleteFile(url)` (log cảnh báo, nuốt lỗi "không tồn tại" nếu convention `deleteFile` như vậy — xác nhận).
   - **Guard DELETE (bắt buộc — chống IDOR):** trước khi gọi `deleteFile(url)` phải: (a) `url` non-empty và là URI http/https hợp lệ; (b) `url` nằm trong **folder logo** (chuỗi path chứa đúng hằng folder logo, vd `.../custom_design_logos/...`). Nếu không thỏa → ném `BadRequestException`/`AppException`, KHÔNG gọi Cloudinary. Việc này giới hạn blast-radius: endpoint không thể xóa ảnh sản phẩm/shop/preview hay asset ngoài folder logo.
   - **Lý do không dùng ownership-by-design:** do upload-on-pick, lúc khách xóa logo giữa chừng thì logo CHƯA thuộc design nào đã lưu, nên không thể verify qua metadata design. Rủi ro tồn dư (user đoán được URL logo chưa lưu của người khác — public_id Cloudinary là ngẫu nhiên, khó đoán, và asset chưa gắn design) được ghi nhận là THẤP; theo dõi uploader theo user là hardening tương lai (out of scope).
3. `CustomDesignMessageConstant.java`: quyết định dùng lại `UPLOAD_FOLDER` hay thêm hằng folder logo (vd `LOGO_UPLOAD_FOLDER = "custom_design_logos"`). Ghi rõ lựa chọn.
4. **Preflight bắt buộc:** đọc `CloudinaryUploadService.validateFile` và ghi rõ giới hạn type/size thực tế. Xác nhận ảnh logo thông thường (png/jpg, tới ~5 MB) qua được. Nếu giới hạn quá chặt khiến logo hợp lệ bị chặn → dừng và báo operator trước khi triển khai Phase 1 (đây là điều kiện tiên quyết, không chỉ là note).

## Tests Planned for Later `ck:test`

- Upload logo hợp lệ → 200 + secure URL; file sai type/quá size → lỗi validate, không gọi Cloudinary.
- Upload yêu cầu auth: request không token → 401/403.
- Delete với URL hợp lệ trong folder logo → gọi `deleteFile(url)` đúng một lần.
- **Guard IDOR**: delete với URL ngoài folder logo (vd URL ảnh sản phẩm) → bị từ chối (BadRequest), KHÔNG gọi `deleteFile`.
- Delete với URL rỗng / không phải http(s) → bị từ chối, không gọi Cloudinary.
- Delete với URL folder logo nhưng không tồn tại → không 500 (theo hành vi `deleteFile`).
- Endpoint không mở transaction (không giữ DB connection).

## Build and Quality Gate

- `./mvnw -q -o compile` exit 0, đọc trọn output.
- `ck:quality --gate` phase này: không blocker/high.
- `git diff --check` sạch ở `java-ecommerce`.

## Success Criteria

- Upload trả về secure Cloudinary URL hợp lệ; delete gọi đúng `deleteFile` cho URL trong folder logo.
- **DELETE từ chối URL ngoài folder logo hoặc URL không hợp lệ** (guard IDOR), không gọi Cloudinary trong các trường hợp đó.
- Cả hai endpoint yêu cầu auth và không `@Transactional`.
- `validateFile` chạy trước upload; giới hạn type/size được ghi nhận và xác nhận cho phép logo thông thường.

## Spec Coverage

- FR-01 (upload endpoint), FR-07 (delete endpoint + guard IDOR), FR-08 (public URL + auth), FR-09 (metadata opaque, không đụng schema).

## Quality and Testing State

- Quality: `ck:quality --gate` approved 2026-07-12 (report: `quality/phase-01-backend-logo-endpoints-quality-report.json`). 0 finding — IDOR guard, transaction boundary, auth pattern đều xác nhận đúng.
- Testing: not started; cases trên để cho `ck:test`.
- Analyze/build gate: `./mvnw -q -o compile` exit 0; `git diff --check` sạch.
