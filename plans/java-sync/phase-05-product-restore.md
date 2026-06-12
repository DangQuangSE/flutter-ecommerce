# Phase 5: Product — restoreProduct

## Requirements
Allow a soft-deleted product to be recovered. This phase also removes `@SQLRestriction` from `Product.java` to match sport_pro_be exactly — sport_pro_be uses only `@SQLDelete`, no `@SQLRestriction`. The delete/restore filter logic is handled in `ProductSpecification` (Phase 6), not at the entity level.

## Key Insight — sport_pro_be Has No @SQLRestriction

`java-ecommerce`'s `Product.java` has:
```java
@SQLDelete(sql = "UPDATE products SET status = 'DELETED' WHERE id = ?")
@SQLRestriction("status <> 'DELETED'")   // ← NOT in sport_pro_be — must be removed
```

`sport_pro_be`'s `Product.java` has only:
```java
@SQLDelete(sql = "UPDATE products SET status = 'DELETED' WHERE id = ?")
```

Because sport_pro_be has no `@SQLRestriction`, `findById` returns deleted products, and `restoreProduct` uses the simple `findById` + `setStatus(ACTIVE)` + `save` pattern. No native queries needed. The `includeDeleted` filtering is done in `ProductSpecification` (see Phase 6).

## Steps

1. Remove `@SQLRestriction("status <> 'DELETED'")` annotation and its import from `Product.java`.

2. Add `void restoreProduct(Long id)` to `IProductService.java`.

3. Implement `restoreProduct` in `ProductService.java` (exact match to sport_pro_be):
   - `findById(id)` → throw `ResourceNotFoundException` if absent
   - `product.setStatus(ProductStatus.ACTIVE)`
   - `productRepository.save(product)`
   - Annotate with `@Transactional`, `@Loggable(action = "RESTORE_PRODUCT", module = "PRODUCT")`, `@CacheEvict(value = {"products","product_details"}, allEntries = true)`

4. Add `PATCH /{id}/restore` endpoint to `AdminProductController.java`.

## Files to Edit

### `Product.java` — remove annotation:
Remove the line:
```java
@SQLRestriction("status <> 'DELETED'")
```
And remove its import if no other class in the file uses it:
```java
import org.hibernate.annotations.SQLRestriction;  // remove if present
```

Keep `@SQLDelete` — it is still used in sport_pro_be.

### `IProductService.java` — add signature:
```java
void restoreProduct(Long id);
```

### `ProductService.java` — add implementation (exact match sport_pro_be lines 142–152):
```java
@Override
@Transactional
@Loggable(action = "RESTORE_PRODUCT", module = "PRODUCT")
@CacheEvict(value = { "products", "product_details" }, allEntries = true)
public void restoreProduct(Long id) {
    Product product = productRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException(
                    ProductMessageConstant.PRODUCT_NOT_FOUND));
    product.setStatus(ProductStatus.ACTIVE);
    productRepository.save(product);
}
```

### `AdminProductController.java` — add endpoint:
```java
@PatchMapping("/{id}/restore")
public ApiResponse<Void> restoreProduct(@PathVariable Long id) {
    productService.restoreProduct(id);
    return ApiResponse.of("Product restored successfully", null);
}
```

## Downstream Impact of Removing @SQLRestriction

With `@SQLRestriction` removed, standard `findById`, `findAll`, and Criteria queries will now return DELETED products. The filtering must be done explicitly in `ProductSpecification.filterProducts` via the `includeDeleted` / `status` parameters (Phase 6). Specifically:

- **Admin listing** (`getProducts`): Phase 6 updates `ProductSpecification` to exclude DELETED unless `includeDeleted=true` or `status=DELETED` is passed.
- **Public listing** (`getProductBySlug`): Already checks `if (product.getStatus() == ProductStatus.DELETED) throw NotFoundException` — safe, matches sport_pro_be line 186–188.
- **Public product by ID**: `getProductById` is admin-only; public routes use slug. If needed, add a status check in the public variant.

## Success Criteria
- `@SQLRestriction` annotation is absent from `Product.java` after this phase
- `PATCH /api/admin/products/{id}/restore` on a product with status DELETED returns `200`
- After restore, `GET /api/admin/products/{id}` returns the product with `"status": "ACTIVE"`
- `PATCH /api/admin/products/{id}/restore` on a non-existent id returns `404`
- Cache is evicted after restore

## Risks
- Removing `@SQLRestriction` makes ALL queries return DELETED products. Phase 6 MUST update `ProductSpecification` to apply the DELETED filter in code. These two phases must be developed together; do not deploy Phase 5 alone without Phase 6.
- If any other code path calls `productRepository.findAll()` without a status filter, it will now include DELETED products. Run a grep for `productRepository.findAll` before committing.

## Dependencies
- None. Can be done before or with Phase 6, but Phase 6 must deploy at the same time.
