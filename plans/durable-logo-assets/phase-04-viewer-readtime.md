# Phase 4: Viewer read-time

## Goal

Design viewer hiển thị logo gốc cho thiết kế mới (từ `logoUrl`) và degrade an toàn cho thiết kế cũ: "unavailable", không rò local path, không crash — preview composite vẫn hiển thị.

## Design Constraints

- Repo: `d:\GitHub\flutter-ecommerce`, `lib/features/customizer/presentation/pages/design_viewer_page.dart`.
- "available" iff `logoUrl` là URL http/https không rỗng. Local path cũ hoặc chuỗi không phải URL → "unavailable".
- Dùng `cached_network_image` (CLAUDE.md) với error/placeholder widget cho ảnh logo.
- KHÔNG in local path ra UI. Mọi chuỗi mới là `AppStrings.*`.
- Không đụng logic parse/preview composite hiện có; metadata malformed vẫn preview-only + warning.
- Preflight: đọc `design_viewer_page.dart` (`_SelectedLayerDetails` ~L106, `_LayerTile` ~L158, `_Preview`); `grep app_strings.dart` xác nhận các hằng `designViewerAssetAvailable`, `designViewerAssetUnavailable`, `designViewerLimited` (đã dùng ở file này nên phải tồn tại) và thêm hằng mới nếu cần cho error widget.

## Exact Files and Steps

1. Thêm helper phân biệt URL: `bool _isRemoteLogo(DesignLayer l) => l.logoUrl != null && (l.logoUrl!.startsWith('http://') || l.logoUrl!.startsWith('https://'))` (hoặc `Uri.tryParse(...)?.hasScheme` kiểm http/https).
2. `_SelectedLayerDetails` (L106): thay điều kiện `logoPath?.isNotEmpty` bằng `_isRemoteLogo(layer)` để quyết định `AppStrings.designViewerAssetAvailable` / `...AssetUnavailable`. Khi available, hiển thị thumbnail logo bằng `CachedNetworkImage(imageUrl: layer.logoUrl!, fit: BoxFit.contain, placeholder: <CircularProgressIndicator nhỏ>, errorWidget: (_, __, ___) => Icon(Icons.broken_image_outlined))` — errorWidget là icon ảnh hỏng (giống `_Preview` hiện có ở L143), KHÔNG hiển thị URL.
3. `_LayerTile` (L158): KHÔNG in `logoPath`. Với logo: nếu remote → nhãn "available" (không in URL dài, hoặc icon), nếu không → `AppStrings.designViewerLimited`/`...AssetUnavailable`. Bỏ việc lộ chuỗi path.
4. Thêm AppStrings mới nếu cần (vd `designViewerAssetUnavailable` đã có — tái dùng; thêm chuỗi cho thumbnail lỗi nếu cần).
5. Giữ nguyên `_Preview` (ảnh composite) — không đổi.

## Tests Planned for Later `ck:test`

- Layer có `logoUrl` http → "available" + render network image (dùng fake/mocked image).
- Layer chỉ có `logoPath` local (thiết kế cũ) → "unavailable", KHÔNG hiển thị local path.
- Layer `logoUrl` rỗng/không phải URL → "unavailable".
- Metadata malformed → preview-only + warning, 0 crash.
- Không overflow ở 360x640 và 428x926.

## Build and Quality Gate

- `dart format` sạch; `flutter analyze` 0 error/warning; `flutter build apk --debug` thành công. Đọc trọn output.
- `ck:quality --gate`: không blocker/high; kiểm riêng: không rò local path, availability đúng theo URL, error widget cho ảnh hỏng.
- `git diff --check` sạch.

## Success Criteria

- Thiết kế mới: logo hiển thị được + "available".
- Thiết kế cũ: "unavailable", không rò local path, 0 crash.
- Ảnh logo hỏng/không tải được → error widget, không crash.

## Spec Coverage

- FR-05 (availability theo URL + render), FR-06 (legacy degrade, không rò path). P1 (admin xem logo mới; logo cũ an toàn).

## Quality and Testing State

- Quality: not evaluated.
- Testing: not started; cases trên để cho `ck:test`.
- Analyze/build gate: not run.
