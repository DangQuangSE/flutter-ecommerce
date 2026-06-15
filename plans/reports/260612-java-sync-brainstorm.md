# Brainstorm: Sync java-ecommerce với sport_pro_be

**Date:** 2026-06-12

## Ideas Explored

- **Exact match (100%)** — bổ sung tất cả gaps để java-ecommerce giống sport_pro_be về API contract, entity, DTO. Không refactor hay thêm feature ngoài scope. ✓ _Đã chọn_
- **Partial sync (chỉ Auth)** — chỉ fix Auth vì FE cần `isActive`. Bỏ qua Product. ✗ _Bị loại: thiếu SizeGroup làm filter sản phẩm theo size không hoạt động_
- **Full rewrite** — xóa java-ecommerce, copy hoàn toàn từ sport_pro_be. ✗ _Bị loại: quá destructive, có thể break custom config_

## User's Direction

Scope: tất cả 3 nhóm (Auth + Product + Other). Approach: Exact match — `java-ecommerce` phải có chính xác cùng API contract như `sport_pro_be`. Không sửa gì ở `sport_pro_be`.

## Gaps Xác Nhận

### Auth Gaps
| Item | java-ecommerce | sport_pro_be |
|------|---------------|--------------|
| `User.isActive` | ❌ Thiếu field | `boolean isActive` (not null, default: true) |
| `UserProfileResponse.isActive` | ❌ Thiếu field | `boolean isActive` |
| `AdminUserController PUT /{id}/role` | ❌ Thiếu | ✅ Có |
| `AdminUserController PUT /{id}/active` | ❌ Thiếu | ✅ Có |
| `AdminUserController DELETE /{id}` | ❌ Thiếu | ✅ Có |
| `IProfileService.updateUserRole()` | ❌ Thiếu | ✅ Có |
| `IProfileService.setUserActive()` | ❌ Thiếu | ✅ Có |
| `IProfileService.deleteUser()` | ❌ Thiếu | ✅ Có |
| `ForgotPasswordController` | ✅ Đã có (sub-module) | ✅ Có |

### Product Gaps
| Item | java-ecommerce | sport_pro_be |
|------|---------------|--------------|
| Module `size` (SizeGroup + SizeOption) | ❌ Thiếu hoàn toàn | ✅ Có |
| `Product.sizeGroup` FK | ❌ Thiếu | `SizeGroup sizeGroup` (nullable) |
| `ProductCreateRequest.sizeGroupId` | ❌ Thiếu | `Long sizeGroupId` |
| `ProductUpdateRequest.sizeGroupId` | ❌ Thiếu | `Long sizeGroupId` |
| `ProductDetailResponse.sizeGroupId` | ❌ Thiếu | `Long sizeGroupId` |
| `IProductService.restoreProduct()` | ❌ Thiếu | `void restoreProduct(Long id)` |
| `IProductVariantService.createVariantsBatch()` | ❌ Thiếu | `List<ProductVariantResponse> createVariantsBatch(...)` |
| `AdminProductController PATCH /{id}/restore` | ❌ Thiếu | ✅ Có |
| `AdminProductController POST /{productId}/variants/batch` | ❌ Thiếu | ✅ Có |
| `AdminProductController GET` includeDeleted param | ❌ Thiếu | `Boolean includeDeleted` (default true) |

## Open Questions

- SizeGroup/SizeOption cần migration script (Liquibase/Flyway) hay chỉ cần entity + `spring.jpa.ddl-auto=update`?
- `deleteUser` trong ProfileService có hard-delete hay soft-delete (set isActive = false)?

## Risks

1. **DB migration**: Thêm `isActive` vào bảng `users` và `size_group_id` FK vào `products` cần migration. Nếu dùng `ddl-auto=update` thì tự động, nhưng nếu production thì cần script.
2. **SizeGroup module location**: sport_pro_be để SizeGroup trong module `size` (không phải `product`). Cần tạo module mới hoặc đặt vào `product` — nên theo đúng sport_pro_be.
3. **FK nullable**: `sizeGroup` trong Product là nullable — không break existing products không có sizeGroup.
