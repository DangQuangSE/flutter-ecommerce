# Brainstorm: Size Group & Size Management

**Date:** 2026-06-15

## Ideas Explored

- **Flutter-only UI first (mock BE)** — Build Flutter screens with hardcoded/mock data, hook up BE later. Dismissed: can't validate real API contract.
- **BE + Flutter song song** — Code cả 2 repo đồng thời. Dismissed: phức tạp, harder to track.
- **BE trước → Flutter sau (selected)** — Implement Service + Controller trong java-ecommerce, sau đó wire Flutter UI. Đảm bảo test end-to-end ngay từ đầu.

## Scout Findings

**Backend (java-ecommerce):**
- `SizeGroup` + `SizeOption` entities & JPA repositories đã tồn tại
- **Không có Service layer và không có REST Controller** cho size management
- Web frontend (sport_pro_fe) gọi `/admin/size-groups` nhưng endpoint chưa tồn tại
- Quan hệ: `SizeGroup` (1) → `SizeOption` (nhiều, có `displayOrder`)
- Product liên kết qua `sizeGroupId` FK (nullable)

**Web reference (sport_pro_fe):**
- API endpoints cần implement: `GET/POST /admin/size-groups`, `PUT/DELETE /admin/size-groups/{id}`, `GET /size-groups` (public)
- UI flow: list panel (trái) + detail editor panel (phải) trong 1 màn hình
- SizeGroup payload: `{ name, description?, sizes: [{ name, displayOrder }] }`
- Product form: dropdown chọn size group (`sizeGroupId`)

**Flutter hiện tại:**
- Không có gì cho size management
- Product form (`admin-product-form` plan) đã có phase cho basic info nhưng chưa có size group selection

## User's Direction

BE trước, Flutter sau. Scope: Admin CRUD size groups + tích hợp vào product form (chọn size group khi tạo/sửa product).

## Open Questions

- Deletion behavior: có cho phép xóa size group đang được dùng bởi product không? (Web gợi ý: không cho phép)
- SizeOption update strategy: replace-all hay patch từng option?

## Risks

1. **BE missing entirely** — Phải build từ đầu cả service + controller trong java-ecommerce trước khi Flutter có thể test
2. **Product form coupling** — Tích hợp size group vào product form đụng vào `admin-product-form` plan đã tồn tại, cần cẩn thận không break existing flow
3. **displayOrder management** — UI cho phép reorder size options; nếu drag-and-drop thì phức tạp hơn input thường
