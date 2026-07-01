# Phase 1: Backend Changes

## Goal
Add image upload endpoint for shop, remove rating/ratingCount from UpdateShopRequest, and compute rating realtime from ProductReview table.

## Files

### 1. `ProductReviewRepository.java`
Add two JPQL queries:
```java
@Query("SELECT AVG(CAST(r.rating AS double)) FROM ProductReview r WHERE r.isActive = true")
Optional<Double> findAverageRating();

@Query("SELECT COUNT(r) FROM ProductReview r WHERE r.isActive = true")
long countActiveReviews();
```

### 2. `ShopServiceImpl.java`
- Inject `ProductReviewRepository reviewRepository`
- In `getShop()`: compute and persist rating/ratingCount before returning:
  ```java
  Shop shop = getOrCreate();
  double avg = reviewRepository.findAverageRating().orElse(0.0);
  long count = reviewRepository.countActiveReviews();
  shop.setRating(BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP));
  shop.setRatingCount((int) count);
  shopRepository.save(shop);
  return toResponse(shop);
  ```
- In `updateShop()`: remove lines `shop.setRating(...)` and `shop.setRatingCount(...)`
- Add new method `uploadShopImage(MultipartFile file, String type)`:
  inject `IUploadService uploadService` and call `uploadService.uploadFile(file, "shop")`

### 3. `IShopService.java`
Add:
```java
String uploadShopImage(MultipartFile file, String type);
```

### 4. `UpdateShopRequest.java`
Remove fields: `rating` (BigDecimal), `ratingCount` (Integer) and their validation annotations.
Keep: `name`, `address`, `phone`, `openingHours`, `description`, `logoUrl`, `coverUrl`

### 5. `AdminShopController.java`
Add upload endpoint:
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

## Acceptance
- `GET /api/shop` returns `rating` and `ratingCount` computed from active ProductReviews
- `POST /api/admin/shop/upload-image` with a valid image returns `{ data: { url: "https://res.cloudinary.com/..." } }`
- `PUT /api/admin/shop` without rating/ratingCount fields still works
- Rating in DB updates whenever `getShop()` is called
