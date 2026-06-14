# Phase 6: Product — Batch Variants + includeDeleted

## Requirements
(1) Create multiple product variants in a single transactional request. (2) Add `includeDeleted` query param to `GET /api/admin/products` — works by updating `ProductSpecification` to handle deleted-product visibility in application code (replacing the removed `@SQLRestriction` from Phase 5).

**This phase must deploy together with Phase 5** — `@SQLRestriction` is removed in Phase 5, and this phase adds the application-level DELETED filter to `ProductSpecification`.

---

## Part A: ProductSpecification — includeDeleted

### Why it works without native queries

sport_pro_be's `Product.java` has no `@SQLRestriction`. Filtering is done purely in `ProductSpecification.filterProducts`. The exact logic from sport_pro_be (line 33–37):

```java
if (status != null) {
    predicates.add(criteriaBuilder.equal(root.get("status"), status));
} else if (!Boolean.TRUE.equals(includeDeleted)) {
    predicates.add(criteriaBuilder.notEqual(root.get("status"), ProductStatus.DELETED));
}
```

When `includeDeleted = true` and `status = null`: no status predicate → all statuses returned (including DELETED).
When `includeDeleted = false` and `status = null`: adds `status <> DELETED` predicate.
When `status` is provided explicitly: filters to that exact status regardless of `includeDeleted`.

### Files to edit

**`ProductSpecification.java`** — update `filterProducts` signature and status predicate (exact match to sport_pro_be):

```java
public static Specification<Product> filterProducts(
        String keyword, Long categoryId, Long brandId, Gender gender, String size, String color,
        BigDecimal minPrice, BigDecimal maxPrice, Boolean isFeatured, ProductStatus status,
        Boolean includeDeleted) {    // NEW parameter

    return (root, query, criteriaBuilder) -> {
        List<Predicate> predicates = new ArrayList<>();

        // ... existing keyword predicate unchanged ...

        // REPLACE the old status block with:
        if (status != null) {
            predicates.add(criteriaBuilder.equal(root.get("status"), status));
        } else if (!Boolean.TRUE.equals(includeDeleted)) {
            predicates.add(criteriaBuilder.notEqual(root.get("status"), ProductStatus.DELETED));
        }

        // ... all other predicates unchanged ...
    };
}
```

**`IProductService.java`** — update `getProducts` signature, add `Boolean includeDeleted` before `Pageable`:
```java
Page<ProductListResponse> getProducts(
    String keyword, Long categoryId, Long brandId, Gender gender,
    String size, String color, BigDecimal minPrice, BigDecimal maxPrice,
    Boolean isFeatured, ProductStatus status,
    Boolean includeDeleted,   // NEW
    Pageable pageable);
```

**`ProductService.java`** — update `@Cacheable` key and method signature:
```java
@Cacheable(value = "products", key = "{#keyword, #categoryId, #brandId, #gender, #size, #color, #minPrice, #maxPrice, #isFeatured, #status, #includeDeleted, #pageable.pageNumber, #pageable.pageSize, #pageable.sort}")
public Page<ProductListResponse> getProducts(..., Boolean includeDeleted, Pageable pageable) {
    Specification<Product> spec = ProductSpecification.filterProducts(
        keyword, categoryId, brandId, gender, size, color,
        minPrice, maxPrice, isFeatured, status, includeDeleted);  // pass includeDeleted
    Page<Product> products = productRepository.findAllWithAssociations(spec, pageable);
    return products.map(this::mapToListResponse);
}
```

**`AdminProductController.java`** — update `getProducts`:
```java
@RequestParam(required = false, defaultValue = "true") Boolean includeDeleted,
// ... existing params ...
// Update the service call to pass includeDeleted:
return ApiResponse.of("...", productService.getProducts(
    keyword, categoryId, brandId, gender, size, color,
    minPrice, maxPrice, status, isFeatured, includeDeleted, pageable));
```

**Caller audit** — find ALL callers of `IProductService.getProducts` before committing:
```
grep -r "getProducts(" src/main/java
```
Expected callers:
- `AdminProductController` — update (above)
- `PublicProductController` — if it calls `getProducts`, update to pass `includeDeleted = false` (public listing should never show deleted products)

---

## Part B: Batch Variant Creation

### Implementation

**`IProductVariantService.java`** — add signature:
```java
List<ProductVariantResponse> createVariantsBatch(Long productId, List<ProductVariantRequest> requests);
```

**`ProductVariantService.java`** — add implementation using `saveAll` (single transaction, single cache evict):
```java
@Override
@Transactional
@CacheEvict(value = {"products", "product_details"}, allEntries = true)
public List<ProductVariantResponse> createVariantsBatch(Long productId, List<ProductVariantRequest> requests) {
    Product product = productRepository.findById(productId)
            .orElseThrow(() -> new ResourceNotFoundException(ProductMessageConstant.PRODUCT_NOT_FOUND));

    List<ProductVariant> variants = new ArrayList<>();
    for (ProductVariantRequest request : requests) {
        if (productVariantRepository.existsBySku(request.getSku())) {
            throw new ConflictException(ProductMessageConstant.SKU_ALREADY_EXISTS);
        }
        Color color = colorRepository.findById(request.getColorId())
                .orElseThrow(() -> new ResourceNotFoundException(ColorMessageConstant.COLOR_NOT_FOUND));

        ProductVariant variant = ProductVariant.builder()
                .product(product)
                .sku(request.getSku())
                .size(request.getSize())
                .color(color)
                .colorOld(color.getName())
                .originalPrice(request.getOriginalPrice())
                .salePrice(request.getSalePrice())
                .stockQuantity(request.getStockQuantity())
                .status(request.getStatus())
                .build();
        variants.add(variant);
    }

    try {
        List<ProductVariant> saved = productVariantRepository.saveAll(variants);
        return saved.stream().map(this::mapToResponse).collect(Collectors.toList());
    } catch (DataIntegrityViolationException ex) {
        // Concurrent insert raced past the existsBySku check — return 409
        throw new ConflictException(ProductMessageConstant.SKU_ALREADY_EXISTS);
    }
}
```

Add import: `import org.springframework.dao.DataIntegrityViolationException;`

**`AdminProductController.java`** — add endpoint:
```java
@PostMapping("/{productId}/variants/batch")
public ApiResponse<List<ProductVariantResponse>> createVariantsBatch(
        @PathVariable Long productId,
        @Valid @RequestBody List<ProductVariantRequest> requests) {
    return ApiResponse.of(ProductMessageConstant.VARIANT_CREATED,
            productVariantService.createVariantsBatch(productId, requests));
}
```

---

## Success Criteria

**includeDeleted:**
- `GET /api/admin/products?includeDeleted=true` returns products including those with `status=DELETED`
- `GET /api/admin/products?includeDeleted=false` returns only ACTIVE/INACTIVE products
- `GET /api/admin/products` (no param, defaultValue="true") includes DELETED products
- Public endpoint (if applicable) never returns DELETED products

**Batch variants:**
- `POST /api/admin/products/{productId}/variants/batch` with 3 variant objects creates all 3 and returns `List<ProductVariantResponse>` with 3 items
- If any SKU in the batch already exists, returns `409` and no variants are saved (whole transaction rolls back)
- Cache evicted exactly once after the batch operation

## Risks
- **MUST deploy with Phase 5**: Removing `@SQLRestriction` (Phase 5) without updating `ProductSpecification` (this phase) would expose all DELETED products in all queries. Deploy atomically.
- SKU uniqueness check in the loop is N individual queries. For batches > 20 variants, consider a bulk `findAllBySkuIn` check upfront — out of scope for this sync but noted.
- `DataIntegrityViolationException` catch converts concurrent-race 500 → 409. The `@Transactional` rollback still happens normally since the exception is re-thrown inside the transaction boundary.

## Dependencies
- Phase 5 must deploy at the same time (or immediately before) this phase.
- Phase 4 (SizeGroup FK) must be complete before `ProductService` changes compile, since `ProductService.getProducts` edits touch the same file.
