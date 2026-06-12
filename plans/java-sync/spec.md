# Spec: Sync java-ecommerce → sport_pro_be

**Date:** 2026-06-12
**Status:** Ready

---

## Problem Statement

`java-ecommerce` thiếu một số entity, field, endpoint so với `sport_pro_be` (reference backend). Flutter frontend gọi API dựa trên contract của sport_pro_be nên các gap này gây lỗi runtime. Cần bổ sung để hai backend có cùng API contract.

---

## User Stories

- **[P1]** As a dev, I want `User.isActive` field to exist so that admin can enable/disable user accounts.
  Accepted when: `GET /api/admin/users` trả về `isActive` trong response; field tồn tại trong DB.

- **[P1]** As an admin, I want `PUT /api/admin/users/{id}/role` and `PUT /api/admin/users/{id}/active` endpoints so that I can manage user roles and status.
  Accepted when: cả hai endpoint trả về `UserProfileResponse` với dữ liệu đã cập nhật.

- **[P1]** As an admin, I want `DELETE /api/admin/users/{id}` to exist so that users can be removed.
  Accepted when: endpoint trả về `204 No Content` sau khi xóa.

- **[P1]** As a dev, I want `SizeGroup` and `SizeOption` entities in a `size` module so that products can reference size groups.
  Accepted when: entity tồn tại, mapped đúng DB table, `Product.sizeGroup` FK hoạt động.

- **[P1]** As an admin, I want `PATCH /api/admin/products/{id}/restore` to exist so that soft-deleted products can be recovered.
  Accepted when: endpoint đổi status từ DELETED → ACTIVE.

- **[P1]** As an admin, I want `POST /api/admin/products/{productId}/variants/batch` to exist so that multiple variants can be created in one request.
  Accepted when: endpoint nhận `List<ProductVariantRequest>`, trả về `List<ProductVariantResponse>`.

- **[P2]** As a dev, I want `ProductCreateRequest`, `ProductUpdateRequest`, `ProductDetailResponse` to include `sizeGroupId` so that size group assignment works end-to-end.
  Accepted when: create/update request chấp nhận `sizeGroupId`; detail response trả về `sizeGroupId`.

- **[P2]** As an admin, I want `GET /api/admin/products` to support `includeDeleted` param so that deleted products can be listed.
  Accepted when: `includeDeleted=true` trả về cả DELETED products; default `true`.

---

## Functional Requirements

### Group 1: Auth — User.isActive

1. **FR-01**: Thêm field `boolean isActive` (not null, `@Column(nullable=false, columnDefinition="boolean default true")`) vào `User.java` entity.
2. **FR-02**: Thêm `boolean isActive` vào `UserProfileResponse` record.
3. **FR-03**: Cập nhật `ProfileService.getAllProfiles()` và `getProfile()` để map `isActive`.

### Group 2: Auth — AdminUserController endpoints

4. **FR-04**: Thêm vào `AdminUserController`:
   ```java
   @PutMapping("/{id}/role")
   public ApiResponse<UserProfileResponse> updateRole(
       @PathVariable Long id,
       @RequestBody Map<String, String> body)

   @PutMapping("/{id}/active")
   public ApiResponse<UserProfileResponse> setActive(
       @PathVariable Long id,
       @RequestBody Map<String, Boolean> body)

   @DeleteMapping("/{id}")
   public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable Long id)
   ```
5. **FR-05**: Thêm 3 method vào `IProfileService`:
   ```java
   UserProfileResponse updateUserRole(Long userId, String role);
   UserProfileResponse setUserActive(Long userId, boolean active);
   void deleteUser(Long userId);
   ```
6. **FR-06**: Implement 3 method mới trong `ProfileService`.

### Group 3: Size Module (mới hoàn toàn)

7. **FR-07**: Tạo module `size` tại `modules/size/`:
   - `domain/SizeGroup.java` — `@Table("size_groups")`, fields: `id`, `name` (unique, length 100, not null), `description` (length 255), `List<SizeOption> sizes` (OneToMany, cascade all, orphanRemoval, EAGER, order by displayOrder ASC)
   - `domain/SizeOption.java` — `@Table("size_options")`, fields: `id`, `name` (length 50, not null), `displayOrder` (not null, default 0), `SizeGroup sizeGroup` (ManyToOne LAZY, FK: size_group_id, not null)
   - `repository/SizeGroupRepository.java` (extends JpaRepository)
   - `repository/SizeOptionRepository.java` (extends JpaRepository)

### Group 4: Product — SizeGroup FK

8. **FR-08**: Thêm vào `Product.java`:
   ```java
   @ManyToOne(fetch = FetchType.LAZY)
   @JoinColumn(name = "size_group_id")
   private SizeGroup sizeGroup;
   ```
9. **FR-09**: Thêm `Long sizeGroupId` vào `ProductCreateRequest` và `ProductUpdateRequest`.
10. **FR-10**: Thêm `Long sizeGroupId` vào `ProductDetailResponse`.
11. **FR-11**: Cập nhật `ProductService.createProduct()` và `updateProduct()` để lookup và set `sizeGroup` nếu `sizeGroupId` != null.
12. **FR-12**: Cập nhật `ProductDetailResponse` mapping để set `sizeGroupId` từ `product.getSizeGroup()`.

### Group 5: Product — restoreProduct

13. **FR-13**: Thêm `void restoreProduct(Long id)` vào `IProductService`.
14. **FR-14**: Implement trong `ProductService`: tìm product (bao gồm DELETED), set status = ACTIVE, save.
15. **FR-15**: Thêm endpoint vào `AdminProductController`:
    ```java
    @PatchMapping("/{id}/restore")
    public ApiResponse<Void> restoreProduct(@PathVariable Long id)
    ```

### Group 6: Product — Batch Variants

16. **FR-16**: Thêm `List<ProductVariantResponse> createVariantsBatch(Long productId, List<ProductVariantRequest> requests)` vào `IProductVariantService`.
17. **FR-17**: Implement trong `ProductVariantService`: loop qua requests, gọi createVariant, collect results.
18. **FR-18**: Thêm endpoint vào `AdminProductController`:
    ```java
    @PostMapping("/{productId}/variants/batch")
    public ApiResponse<List<ProductVariantResponse>> createVariantsBatch(
        @PathVariable Long productId,
        @Valid @RequestBody List<ProductVariantRequest> requests)
    ```

### Group 7: includeDeleted param

19. **FR-19**: Cập nhật `AdminProductController.getProducts()` để nhận `@RequestParam(required=false, defaultValue="true") Boolean includeDeleted`.
20. **FR-20**: Truyền `includeDeleted` vào `IProductService.getProducts()` signature và implementation.

---

## Non-Functional Requirements

- Security: các endpoint `PUT /{id}/role`, `PUT /{id}/active`, `DELETE /{id}` phải có `@PreAuthorize("hasRole('ADMIN')")` — giống pattern hiện có trong AdminUserController.
- Backward compatibility: `sizeGroup` FK trong Product là nullable — không break existing products.
- DB schema: dùng `spring.jpa.ddl-auto=update` để tự apply schema changes (môi trường dev). Production cần manual migration script.

---

## Success Criteria

- [ ] `GET /api/admin/users` response chứa `isActive` field
- [ ] `PUT /api/admin/users/{id}/role` trả về `200` với role đã update
- [ ] `PUT /api/admin/users/{id}/active` trả về `200` với `isActive` đã đổi
- [ ] `DELETE /api/admin/users/{id}` trả về `200`
- [ ] `SizeGroup` và `SizeOption` tables tồn tại trong DB sau khi app start
- [ ] `POST /api/admin/products` chấp nhận `sizeGroupId` và `GET /{id}` trả về `sizeGroupId`
- [ ] `PATCH /api/admin/products/{id}/restore` đổi status từ DELETED → ACTIVE
- [ ] `POST /api/admin/products/{productId}/variants/batch` tạo nhiều variants trong 1 request
- [ ] `GET /api/admin/products?includeDeleted=true` trả về cả DELETED products

---

## Out of Scope

- Không tạo Public API endpoint cho SizeGroup (chỉ cần entity + FK cho Product)
- Không sửa `sport_pro_be`
- Không thêm Liquibase/Flyway migration script (chỉ dùng ddl-auto=update)
- Không thay đổi CartController, OrderController, hay các module khác

---

## Assumptions

- `java-ecommerce` dùng `spring.jpa.ddl-auto=update` → schema tự update khi thêm field/table mới
- `deleteUser` là hard-delete (xóa hẳn row) — giống pattern trong sport_pro_be ProfileService
- `restoreProduct` tìm product kể cả khi status=DELETED (cần bypass `@SQLRestriction` nếu có)
- Product soft-delete dùng `@SQLDelete` annotation (set status='DELETED') — pattern đã có trong sport_pro_be
