# Phase 2: Flutter data/domain

## Goal

Thêm `logoUrl` vào model layer và cung cấp đường data/domain (datasource → repository → usecase) để upload một file logo và xóa logo theo URL, đăng ký DI, tương thích ngược với metadata cũ.

## Design Constraints

- Repo: `d:\GitHub\flutter-ecommerce`. Theo Clean Architecture + `Result<T>` (không throw xuyên tầng), DI trong module không trong widget (CLAUDE.md).
- `DesignLayer` thêm `logoUrl` (String?, http/https). `toJson`/`fromJson`/`copyWith` serialize `logoUrl`. GIỮ `logoPath` để đọc metadata cũ; layer mới ghi `logoUrl`, không ghi `logoPath`.
- Parser (`design_metadata_parser.dart`) strict chỉ với `id/type/view/color/fontSize/x/y`, lenient với field optional → thêm `logoUrl` an toàn, KHÔNG sửa logic strict.
- Datasource theo đúng mẫu Dio `MultipartFile` của `saveDesign` trong `custom_design_remote_datasource_impl.dart`.
- Preflight: đọc `design_layer.dart`, `design_metadata_parser.dart`, `custom_design_remote_datasource.dart`(+impl), `custom_design_repository.dart`(+impl), `customizer_module.dart`, một usecase mẫu để khớp chữ ký `Result<T>` + cách register DI.

## Exact Files and Steps

1. `lib/features/customizer/presentation/models/design_layer.dart`: thêm field `final String? logoUrl;`, vào constructor, `copyWith`, `toJson` (`'logoUrl': logoUrl`), `fromJson` (`logoUrl: json['logoUrl'] as String?`). Giữ nguyên `logoPath`.
2. `custom_design_remote_datasource.dart` (+ `_impl.dart`): thêm `Future<String> uploadLogo(<file/bytes>)` (multipart `file`, đọc URL từ `ApiResponse`) và `Future<void> deleteLogo(String url)` (DELETE với query `url`). Xử lý lỗi mạng → ném DioException để tầng repo map sang Failure.
3. `custom_design_repository.dart` (+ impl): thêm `Future<Result<String>> uploadLogo(...)` và `Future<Result<void>> deleteLogo(String url)`; map exception → `Failure` theo convention repo hiện có.
4. `lib/features/customizer/domain/usecases/`: thêm `upload_logo_usecase.dart` và `delete_logo_usecase.dart` (mỏng, gọi repository), theo mẫu usecase hiện có.
5. `customizer_module.dart`: register 2 usecase mới (và bảo đảm datasource/repository đã có DI). Không tạo `locator<T>()` trong widget.

## Tests Planned for Later `ck:test`

- `DesignLayer.fromJson` với các biến thể `logoUrl`: vắng field (metadata cũ chỉ có `logoPath`), `null` tường minh, chuỗi rỗng `""`, chuỗi không phải URL (`"abc"`), sai kiểu (số) → không crash; availability sau đó tính đúng (chỉ http/https mới "available").
- Có cả `logoPath` lẫn `logoUrl` (trạng thái hỗn hợp) → đọc được, `logoUrl` thắng khi hiển thị.
- Round-trip toJson/fromJson giữ `logoUrl` (kể cả URL dài/ký tự đặc biệt/Unicode) không mất dữ liệu.
- Parser vẫn parse metadata cũ và mới không sinh warning sai (logic strict id/type/view/color/fontSize/x/y không đổi).
- Datasource uploadLogo trả URL từ payload; deleteLogo gọi đúng path + query `url`.
- Repository map lỗi mạng → `ResultFailure` (không throw xuyên tầng).

## Build and Quality Gate

- `dart format` sạch trên file đụng tới; `flutter analyze` 0 error/warning; `flutter build apk --debug` thành công. Đọc trọn output.
- `ck:quality --gate` phase này: không blocker/high.
- `git diff --check` sạch.

## Success Criteria

- `logoUrl` serialize/deserialize đúng; metadata cũ vẫn parse (backward-compatible).
- uploadLogo/deleteLogo có mặt xuyên datasource→repository→usecase, trả `Result<T>`.
- DI đăng ký đủ; không có `locator<T>()` trong widget.

## Spec Coverage

- FR-02 (logoUrl field + backward-compat), FR-03 (đường data cho upload), FR-07 (đường data cho delete).

## Quality and Testing State

- Quality: `ck:quality --gate` approved 2026-07-12 (report + receipt: `quality/phase-02-flutter-data-domain-quality-report.json`/`-receipt.json`). 1 NOTED (pre-existing CRLF blob encoding in 2 file trước khi phase này chạm vào, không phải trailing whitespace thật) — không block.
- Testing: not started; cases trên để cho `ck:test`.
- Analyze/build gate: `dart format` sạch, `flutter analyze` 0 error/warning, `flutter build apk --debug` thành công, `git diff --check` sạch trên 7/9 file (2 file còn lại pre-existing, xem note).
