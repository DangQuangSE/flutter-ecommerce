# Phase 2: Flutter Data Layer

## Goal
Add `uploadShopImage` to datasource and repository.

## Files

### 1. `shop_remote_datasource.dart`
Add to abstract interface:
```dart
Future<String> uploadShopImage(File file, String type);
```

### 2. `shop_remote_datasource_impl.dart`
Implement using Dio FormData (same pattern as admin_product_image_datasource_impl.dart):
```dart
Future<String> uploadShopImage(File file, String type) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path, filename: basename(file.path)),
    'type': type,
  });
  final response = await _dioClient.dio.post<Map<String, dynamic>>(
    '${ApiConstants.adminShop}/upload-image',
    data: formData,
  );
  final url = response.data?['data']?['url'] as String?;
  if (url == null) throw const ParseException('URL ảnh không hợp lệ');
  return url;
}
```

### 3. `shop_repository.dart` (abstract)
Add:
```dart
Future<String?> uploadShopImage(File file, String type);
```

### 4. `shop_repository_impl.dart`
Delegate to datasource, wrap in try/catch, return null on error.

## Notes
- Import `dart:io` for `File`
- Import `path/path.dart` for `basename` (already in pubspec as `path` package)
- ApiConstants.adminShop should be `/api/admin/shop` — verify in api_constants.dart

## Acceptance
- Calling `uploadShopImage(file, 'logo')` returns a Cloudinary URL string
- Network error returns null (not throws)
