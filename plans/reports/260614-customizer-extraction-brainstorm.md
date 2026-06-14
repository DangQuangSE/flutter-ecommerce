# Brainstorm: Customizer Feature Extraction + Agent Creation

**Date:** 2026-06-14

---

## Ideas Explored

**Option A — Hard cut (selected):** Tách hoàn toàn `customizer` thành feature độc lập với đủ 3 layer (data/domain/presentation). CartCubit dependency giải quyết bằng callback/use case.

**Option B — Shared widgets:** Thêm bước di chuyển product widgets (ColorSelector, SizeSelector…) vào `core/widgets/`. Bị loại khỏi scope này vì scope đủ rộng rồi — để sang iteration sau.

**Option C — Chỉ tách presentation:** Giữ CustomizerCubit + CustomDesignRepository trong product, chỉ move page. Bị loại vì làm cấu trúc rối hơn, không đạt tiêu chí giáo viên.

---

## User's Direction

> "Tách ra hoàn toàn độc lập khỏi product"
> Widget split level: 5 widget lớn (CanvasWorkspace, ConfigPanel, LayerEditor, PricingFooter, ColorPicker)
> 2 agents: flutter-refactorer (move + import), flutter-reviewer (review + test + report)
> Agents: file trong .claude/agents/ + tích hợp vào pipeline

---

## Scout Findings (Key Facts)

- `ProductCustomizerPage`: **1632 dòng**, tất cả logic inline trong build — vi phạm nặng tiêu chí 3
- Files cần move: `customizer_cubit.dart`, `customizer_state.dart`, `custom_design_*.dart` (4 files), `customization_entity.dart`
- Printing prices hardcode trong page: `30000đ` (nhiệt), `50000đ` (decal), `10000đ/layer`
- Coupling chính: `CartCubit.addItem(customDesignId: ...)` — gọi trực tiếp `sl<CartCubit>()`
- `ProductDetailPage` dùng `CustomizerCubit` để hiển thị customization badge
- `injection_container.dart` đăng ký 3 customizer singletons cần update path

---

## Open Questions (cho /ck:plan giải quyết)

1. Cart dependency: dùng callback param hay tạo `AddToCartWithDesignUseCase`?
2. `ProductDetailPage` đang import `CustomizerCubit` — update import path hay tạo interface?
3. `PrintingColorCubit` (trong `color/` feature) có cần di chuyển hoặc reference vào customizer không?
4. Route `/customizer/:productId` đang nằm trong `app_router.dart` — BlocProvider cần update

---

## Risks

1. **Import path breakage** — 1632-line page dùng nhiều packages; missing import = compile error. Cần migrate từng bước.
2. **CartCubit coupling** — Nếu tách không sạch, Cart sẽ gọi sang Customizer feature tạo circular dependency.
3. **SharedPreferences key conflict** — `CustomizerCubit` persist với key `'customizations'` — không đổi key thì migration safe.
