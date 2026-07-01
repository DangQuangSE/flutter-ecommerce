# Spec: Admin Shop Config Page Redesign

**Feature:** Redesign Admin Shop Configuration
**Date:** 2026-07-02
**Status:** Ready for planning

---

## Problem

The current admin shop config page is a plain vertical list of TextFields, including editable `ratingCount` and `rating` fields that should be computed automatically. Logo and cover image fields are plain URL text inputs — no preview or upload UX.

## Goal

1. Remove `ratingCount` field from form (computed by backend from product reviews)
2. Remove `rating` field from form (computed by backend realtime)
3. Replace logo URL text field → circular image picker with live preview
4. Replace cover URL text field → full-width cover image picker with live preview
5. Redesign layout: cover picker at top → logo avatar overlapping bottom-left → fields below (mirrors "Thông tin cửa hàng" style but editable)
6. Add backend endpoint `POST /api/admin/shop/upload-image` for image upload to Cloudinary

---

## User Stories

| # | Story | Priority |
|---|-------|----------|
| P1 | Admin taps cover area → picks from gallery → image uploads to Cloudinary → preview updates | P1 |
| P1 | Admin taps logo avatar → picks from gallery → uploads → circular preview updates | P1 |
| P1 | Admin edits name, address, phone, openingHours, description → saves → redirects back | P1 |
| P1 | Rating and ratingCount are NOT shown in the admin form (removed entirely) | P1 |
| P2 | Upload in progress shows loading indicator on the image area | P2 |
| P2 | Upload failure shows snackbar error, field stays unchanged | P2 |
| P3 | If no image selected, show placeholder with camera icon | P3 |

---

## Success Criteria

- `ratingCount` and `rating` fields are gone from the admin form
- Tapping cover/logo area opens image picker
- After picking, image uploads immediately; preview shows new image within 3s on good network
- Form still submits as JSON PUT (only URLs change, not multipart)
- `flutter analyze` reports zero errors after changes
- No RenderFlex overflow on 360px wide screen

---

## Architecture

### Backend (Spring Boot)

**New endpoint:**
```
POST /api/admin/shop/upload-image
Content-Type: multipart/form-data
Params: file (MultipartFile), type (String: "logo" | "cover")
Response: { "data": { "url": "https://res.cloudinary.com/..." } }
```

- Reuses `CloudinaryUploadService.uploadFile(file, "shop")`
- Requires ADMIN role (same as other `/api/admin/**` routes)
- Returns wrapped in existing `ApiResponse<Map>` pattern

**UpdateShopRequest:** Remove `rating` and `ratingCount` fields.
**ShopService.updateShop:** Do not update `rating`/`ratingCount` from request; these are computed.

### Flutter

**New datasource method on `ShopRemoteDataSource`:**
```dart
Future<String> uploadShopImage(File file, String type); // returns URL
```

**`ShopCubit`** — add method:
```dart
Future<String?> uploadShopImage(File file, String type);
```

**`AdminShopConfigPage`** — full rewrite of `_AdminShopForm`:
- `Stack` layout: cover picker (height ~200) + logo avatar (80px circle, positioned bottom-left of cover)
- Remove `_ratingCtrl`, `_ratingCountCtrl`, `_logoUrlCtrl`, `_coverUrlCtrl` TextEditingControllers
- Add `File? _pendingLogoFile`, `File? _pendingCoverFile` for local state before upload  
- Add `String? _logoUrl`, `String? _coverUrl` initialized from `initialShop`
- On image pick: call `cubit.uploadShopImage()` → update URL state
- Submit: use stored `_logoUrl`/`_coverUrl` in `copyWith`

**New widgets (in `lib/features/shop/presentation/widgets/`):**
- `shop_cover_picker.dart` — full-width tappable cover with camera overlay
- `shop_logo_picker.dart` — circular avatar with camera overlay

**`AppStrings`** — add new keys for upload states, remove unused shop field strings for rating.

**`ShopEntity`** — keep `rating` and `ratingCount` fields (still received from GET), just not editable.

---

## Files to Touch

### Backend
- `AdminShopController.java` — add upload endpoint
- `UpdateShopRequest.java` — remove rating/ratingCount fields
- `ShopServiceImpl.java` — do not set rating/ratingCount from request

### Flutter
- `shop_remote_datasource.dart` — add `uploadShopImage` method
- `shop_remote_datasource_impl.dart` — implement upload via multipart Dio
- `shop_repository.dart` — add method signature
- `shop_repository_impl.dart` — delegate to datasource
- `shop_cubit.dart` — add `uploadShopImage` method
- `admin_shop_config_page.dart` — full layout redesign
- `shop_cover_picker.dart` — NEW widget
- `shop_logo_picker.dart` — NEW widget
- `app_strings.dart` — add/update constants

---

## Out of Scope

- Deleting old Cloudinary image when replaced (nice to have, defer)
- Cropping/editing image before upload
- Rating display on the admin page (shown on public ShopInfoPage only)
