# Phase 3: Flutter Cubit Layer

## Goal
Add upload capability to ShopCubit. No new state class needed — upload is handled as a Future return, not via global state (avoids interfering with ShopLoaded state during upload).

## Files

### 1. `shop_cubit.dart`
Add method:
```dart
/// Returns error message string on failure, null on success.
Future<String?> uploadShopImage(File file, String type) async {
  final url = await _repository.uploadShopImage(file, type);
  if (url == null) return AppStrings.shopImageUploadError;
  return null; // success — caller stores the URL in local widget state
}

/// Returns (url, null) on success, (null, errorMessage) on failure.
Future<(String?, String?)> uploadShopImageWithUrl(File file, String type) async {
  final url = await _repository.uploadShopImage(file, type);
  if (url == null) return (null, AppStrings.shopImageUploadError);
  return (url, null);
}
```

Use `uploadShopImageWithUrl` — returns a record so the caller (widget) can store the URL.

## Notes
- Upload is fire-and-return, not state-machine-based. The page widget manages `_isUploadingLogo` / `_isUploadingCover` via `setState` (local UI state — acceptable per grading rules since it's purely ephemeral UI state).
- `ShopState` is unchanged.

## Acceptance
- `cubit.uploadShopImageWithUrl(file, 'logo')` returns `('https://...', null)` on success
- Returns `(null, 'error message')` on network failure
