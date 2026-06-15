# Spec: Size Group & Size Management

**Date:** 2026-06-15
**Status:** Ready

---

## Problem Statement

Admin cần quản lý các nhóm kích thước (size groups) và kích thước cụ thể (size options) trong ứng dụng Flutter, tương đồng với web admin. Backend chưa có API endpoints cho size management — phải implement BE trước, Flutter sau.

---

## User Stories

- **[P1]** As an admin, I want to view a list of all size groups so that I can see what presets exist.
  Accepted when: màn hình list hiển thị tên, mô tả, và preview sizes của mỗi group.

- **[P1]** As an admin, I want to create a new size group with name, description, and size options (name + displayOrder) so that I can define new presets.
  Accepted when: POST thành công → group xuất hiện trong list; validation bắt lỗi tên trùng và tên trống.

- **[P1]** As an admin, I want to edit an existing size group (name, description, size options) so that I can correct or expand it.
  Accepted when: PUT thành công → list refresh với data mới.

- **[P1]** As an admin, I want to delete a size group so that I can remove unused presets.
  Accepted when: DELETE thành công → group biến mất khỏi list; server trả lỗi nếu group đang dùng bởi product.

- **[P1]** As an admin, I want to select a size group when creating or editing a product so that the product is linked to the correct size preset.
  Accepted when: product form có dropdown chọn size group; chọn xong save thì `sizeGroupId` được gửi lên BE.

- **[P2]** As an admin, I want to reorder size options within a group using displayOrder so that sizes appear in a logical sequence.
  Accepted when: có nút lên/xuống hoặc số input để set displayOrder; thứ tự lưu đúng sau PUT.

---

## Functional Requirements

### Backend (java-ecommerce)

1. **FR-01:** Tạo `ISizeGroupService` với methods: `getAll()`, `create(SizeGroupRequest)`, `update(Long id, SizeGroupRequest)`, `delete(Long id)`.
2. **FR-02:** Tạo `SizeGroupRequest` DTO: `{ name: String (required), description: String (optional), sizes: List<SizeOptionRequest> }` — `SizeOptionRequest`: `{ name: String, displayOrder: int }`.
3. **FR-03:** Tạo `SizeGroupResponse` DTO mirror từ entity (id, name, description, sizes[]).
4. **FR-04:** Tạo `AdminSizeGroupController` tại `/api/admin/size-groups` với: `GET /`, `POST /`, `PUT /{id}`, `DELETE /{id}` — tất cả yêu cầu ADMIN role.
5. **FR-05:** Tạo public endpoint `GET /api/size-groups` (không cần auth) để Flutter product form lấy danh sách.
6. **FR-06:** `delete` phải kiểm tra FK constraint — nếu size group đang được dùng bởi ≥1 product thì trả `400 Bad Request` với message rõ ràng.
7. **FR-07:** Update strategy cho sizes: replace-all (xóa toàn bộ `SizeOption` cũ, insert lại từ request).

### Flutter (flutter-ecommerce)

8. **FR-08:** Tạo feature `features/size/` theo Clean Architecture: domain (entities, repo interface, use cases), data (models, datasource, repo impl), presentation (cubit, pages, widgets).
9. **FR-09:** `SizeGroupListPage` — hiển thị danh sách size groups, có nút tạo mới và nút xóa với confirm dialog.
10. **FR-10:** `SizeGroupFormPage` — form tạo/sửa size group: text fields cho name + description, dynamic list editor cho size options (add/remove/reorder), Save button.
11. **FR-11:** Cubit expose states: `Initial | Loading | Success(List<SizeGroup>) | Error(String) | Empty`.
12. **FR-12:** Tích hợp vào product form: dropdown `sizeGroupId` trong Basic Info step, load từ `GET /api/size-groups`, nullable (có option "Không có size group").
13. **FR-13:** Tất cả network errors phải hiển thị snackbar hoặc error state rõ ràng.

---

## Non-Functional Requirements

- Security: `/api/admin/size-groups` yêu cầu JWT với role ADMIN (giống các admin endpoints khác).
- Usability: Size options có thể thêm/xóa inline trong form, không cần popup riêng.
- Consistency: Follow cùng pattern với admin product management (Cubit, GoRouter, GetIt).

---

## Success Criteria

- [ ] `dart analyze` zero errors sau khi implement Flutter feature
- [ ] `flutter build apk --debug` thành công
- [ ] CRUD size group hoàn chỉnh: tạo → list hiện → sửa → xóa, tất cả reflect đúng trong DB
- [ ] Product form dropdown load đúng list size groups từ API
- [ ] Xóa size group đang dùng → app hiển thị error message thay vì crash
- [ ] Size options giữ đúng `displayOrder` sau khi save

---

## Out of Scope

- Bulk variant generation từ size group (color × size) — thuộc scope `admin-product-form` plan riêng
- Customer-facing size selection — đã xử lý qua product variants
- Drag-and-drop reorder UI — dùng số input cho displayOrder thay thế
- Size option soft-delete hay archive

---

## Assumptions

- BE `SizeGroup` + `SizeOption` entities và repositories đã có, không cần thay đổi schema
- Flutter app đã có JWT interceptor và admin auth flow hoạt động
- Product form (`admin-product-form`) đã tồn tại và có `sizeGroupId` field trong `ProductCreateRequest`/`ProductUpdateRequest` trên BE
- Replace-all strategy cho sizes là acceptable (không cần granular patch)

---

## Implementation Order

**Phase 1 — Backend** (java-ecommerce):
- DTOs: `SizeGroupRequest`, `SizeGroupResponse`, `SizeOptionRequest`
- Service: `ISizeGroupService` + `SizeGroupService`
- Controllers: `AdminSizeGroupController` + public endpoint

**Phase 2 — Flutter Data Layer**:
- Models: `SizeGroupModel`, `SizeOptionModel` với `fromJson`/`toJson`
- Datasource: `SizeGroupRemoteDatasource`
- Repository: `SizeGroupRepository` (domain + impl)

**Phase 3 — Flutter Domain Layer**:
- Entities: `SizeGroup`, `SizeOption`
- Use cases: `GetSizeGroups`, `CreateSizeGroup`, `UpdateSizeGroup`, `DeleteSizeGroup`

**Phase 4 — Flutter Presentation**:
- Cubit: `SizeGroupCubit` + states
- Pages: `SizeGroupListPage`, `SizeGroupFormPage`
- Widgets: `SizeGroupCard`, `SizeOptionListEditor`
- DI + Router wiring

**Phase 5 — Product Form Integration**:
- Thêm `sizeGroupId` dropdown vào Basic Info step của product form
- Load size groups từ public API
