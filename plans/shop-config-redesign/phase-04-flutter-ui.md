# Phase 4: Flutter UI Redesign

## Goal
Full redesign of `admin_shop_config_page.dart` with profile-card layout + image pickers. Extract 2 new picker widgets.

## Layout Structure

```
Scaffold
└─ SingleChildScrollView
   └─ Column
      ├─ _ShopCoverPicker (Stack, height ~220)
      │    ├─ AspectRatio(16/9) or SizedBox(height: 200) — cover image / placeholder
      │    └─ Positioned(bottom: -40, left: 16) → _ShopLogoPicker (80px circle)
      ├─ SizedBox(height: 48)   ← space for avatar overflow
      ├─ Padding → Column (form fields)
      │    ├─ _buildField(name, required)
      │    ├─ _buildField(address)
      │    ├─ _buildField(phone)
      │    ├─ _buildField(openingHours)
      │    └─ _buildField(description, maxLines:4)
      └─ _SubmitButton
```

Note: Stack `clipBehavior: Clip.none` to allow logo picker to overflow below cover.

## New Files

### `lib/features/shop/presentation/widgets/shop_cover_picker.dart`

```dart
class ShopCoverPicker extends StatelessWidget {
  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onTap;

  // Shows: CachedNetworkImage if imageUrl != null, else grey placeholder with camera icon
  // Camera icon overlay in bottom-right corner
  // Shows CircularProgressIndicator overlay when isUploading
}
```

### `lib/features/shop/presentation/widgets/shop_logo_picker.dart`

```dart
class ShopLogoPicker extends StatelessWidget {
  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onTap;

  // 80px circular CachedNetworkImage or placeholder
  // Small camera badge in bottom-right
  // White border (2px) + shadow to float above cover
  // Shows CircularProgressIndicator when isUploading
}
```

## Changes to `admin_shop_config_page.dart`

### State changes
Remove:
- `_ratingCtrl`, `_ratingCountCtrl`, `_logoUrlCtrl`, `_coverUrlCtrl`
- `_validateRating()`, `_validateRatingCount()`

Add:
- `String? _logoUrl` (initialized from `widget.initialShop.logoUrl`)
- `String? _coverUrl` (initialized from `widget.initialShop.coverUrl`)
- `bool _isUploadingLogo = false`
- `bool _isUploadingCover = false`

### Image pick handler
```dart
Future<void> _pickAndUploadImage(String type) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  if (picked == null || !mounted) return;

  setState(() => type == 'logo' ? _isUploadingLogo = true : _isUploadingCover = true);

  final (url, error) = await context.read<ShopCubit>().uploadShopImageWithUrl(
    File(picked.path), type,
  );

  if (!mounted) return;
  setState(() {
    type == 'logo' ? _isUploadingLogo = false : _isUploadingCover = false;
    if (url != null) {
      type == 'logo' ? _logoUrl = url : _coverUrl = url;
    }
  });

  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: AppColors.error),
    );
  }
}
```

### Submit changes
In `_submit()`, use `_logoUrl` and `_coverUrl` instead of controller text:
```dart
final draft = widget.initialShop.copyWith(
  name: _nameCtrl.text.trim(),
  address: ...,
  phone: ...,
  openingHours: ...,
  description: ...,
  logoUrl: _logoUrl,
  coverUrl: _coverUrl,
  // NO rating, NO ratingCount
);
```

## AppStrings additions
```dart
static const String shopImageUploadError = 'Tải ảnh lên thất bại. Vui lòng thử lại.';
static const String shopCoverPickerHint = 'Nhấn để thay đổi ảnh bìa';
static const String shopLogoPickerHint = 'Nhấn để thay đổi logo';
// Remove: shopFieldRatingCount, shopFieldRatingCountHint, shopValidationRatingCount*
// Remove: shopFieldRating, shopFieldRatingHint, shopValidationRating*
// Remove: shopFieldLogoUrl, shopFieldLogoUrlHint, shopFieldCoverUrl, shopFieldCoverUrlHint
```

## pubspec.yaml check
Verify `image_picker` is present. If not, add:
```yaml
image_picker: ^1.1.2
```

## Android permissions (android/app/src/main/AndroidManifest.xml)
Add inside `<manifest>` tag if not already present:
```xml
<!-- image_picker: Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<!-- image_picker: Android < 13 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
```

## Acceptance
- Cover area tap → gallery → upload → preview updates
- Logo area tap → gallery → upload → circular preview updates
- Rating and ratingCount fields are gone
- Submit uses _logoUrl/_coverUrl (not text fields)
- `flutter analyze` zero errors
- No RenderFlex overflow on 360px width
