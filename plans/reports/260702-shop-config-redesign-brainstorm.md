# Brainstorm: Admin Shop Config Page Redesign

**Date:** 2026-07-02

## Ideas Explored

- **Upload via backend proxy** (chosen): Flutter picks image → POST multipart to Spring Boot `/api/admin/shop/upload-image` → backend calls CloudinaryUploadService → returns URL. Keeps credentials server-side, reuses existing infrastructure.
- **Direct Cloudinary upload from Flutter**: Flutter SDK uploads directly, no backend proxy. Rejected — exposes Cloudinary credentials on device.
- **Upload on save**: Bundle image as multipart with all form fields on submit. Rejected — would require rewriting the entire PUT endpoint to multipart; JSON approach is simpler and already working.
- **Separate upload endpoint + JSON PUT** (chosen): Upload image separately on pick, get URL, store in local state, submit form as JSON with updated URL. Non-breaking, minimal backend change.

## User's Direction

- **Rating & ratingCount**: Both removed from admin form. Backend computes them realtime from review data. Still displayed read-only in the public "Thông tin cửa hàng" screen.
- **Image upload**: Via backend (Spring Boot → Cloudinary), not direct from Flutter.
- **Layout**: Form but with "Thông tin cửa hàng" visual style — cover image picker at top, circular logo avatar picker overlapping, then editable fields below.

## Open Questions

- What folder name on Cloudinary for shop images? (suggest `"shop"`)
- Should the old Cloudinary image be deleted when a new one is uploaded? (suggest yes, backend handles cleanup)
- `image_picker` package — already in pubspec.yaml? (need to verify)

## Risks

1. `image_picker` permission handling on Android (READ_MEDIA_IMAGES) — needs manifest config
2. Backend PUT endpoint currently excludes `rating`/`ratingCount` from UpdateShopRequest — need to ensure that's correct or add computed values to GET response
3. Layout overlap (logo avatar on cover) requires careful Stack positioning to avoid overflow on small screens
