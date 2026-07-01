# Phase 1: Backend Changes

## Goal
Add image upload endpoint for shop and remove rating/ratingCount from UpdateShopRequest.

## Files

### 1. `AdminShopController.java`
Add new endpoint:
```java
@PostMapping("/upload-image")
public ApiResponse<Map<String, String>> uploadShopImage(
    @RequestParam("file") MultipartFile file,
    @RequestParam("type") String type
) {
    String url = shopService.uploadShopImage(file, type);
    return ApiResponse.of("Tải ảnh lên thành công", Map.of("url", url));
}
```

### 2. `IShopService.java` (interface)
Add method signature:
```java
String uploadShopImage(MultipartFile file, String type);
```

### 3. `ShopServiceImpl.java`
Implement the method — call `uploadService.uploadFile(file, "shop")` and return the URL.
Also: in `updateShop()`, ensure rating/ratingCount are NOT updated from request (keep existing values from DB).

### 4. `UpdateShopRequest.java`
Remove fields: `rating`, `ratingCount`
Keep: `name`, `address`, `phone`, `openingHours`, `description`, `logoUrl`, `coverUrl`

## Acceptance
- `POST /api/admin/shop/upload-image` with a valid image returns `{ data: { url: "https://res.cloudinary.com/..." } }`
- `PUT /api/admin/shop` with body missing rating/ratingCount still works
- Existing GET /api/shop still returns rating and ratingCount (computed from DB)
