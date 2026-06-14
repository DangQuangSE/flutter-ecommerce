# Spec: Customizer Feature Extraction + Project Agents

**Date:** 2026-06-14
**Status:** Ready

---

## Problem Statement

Feature customizer/printing đang nằm lẫn trong `features/product/`, vi phạm nguyên tắc feature isolation và khiến `ProductCustomizerPage` đạt 1632 dòng (tiêu chí 3 của giáo viên yêu cầu `build()` < 50 dòng). Cần tách thành feature độc lập và tạo 2 agent chuyên biệt để tự động hóa refactor + review trong tương lai.

---

## User Stories

- **[P1]** As a developer, I want `customizer` to be a standalone feature so that adding/changing printing logic doesn't touch `product/`.
  Accepted when: không có `import` nào từ `customizer/` sang `product/` và ngược lại (ngoại trừ shared entities ở `core/`).

- **[P1]** As a developer, I want `ProductCustomizerPage` split into 5 widgets so that `build()` stays under 60 lines.
  Accepted when: `customizer_page.dart` build() ≤ 60 dòng; mỗi widget con ≤ 200 dòng.

- **[P1]** As a developer, I want printing price constants centralized so that changing 30.000đ → 35.000đ chỉ sửa 1 file.
  Accepted when: `core/constants/printing_constants.dart` tồn tại; page không chứa magic number giá.

- **[P1]** As a developer, I want a `flutter-refactorer` agent that moves files and updates imports without breaking builds.
  Accepted when: agent file `.claude/agents/flutter-refactorer.md` tồn tại; agent được invoke trong `/ck:cook` pipeline.

- **[P1]** As a developer, I want a `flutter-reviewer` agent that checks grading criteria and runs tests.
  Accepted when: agent file `.claude/agents/flutter-reviewer.md` tồn tại; agent report gồm verdict + severity counts.

- **[P2]** As a developer, I want CartCubit coupling resolved via a use case or callback so that `customizer` doesn't import from `cart/` directly.
  Accepted when: `customizer/` không có `import` nào vào `features/cart/`.

- **[P3]** _(future)_ Move `ColorSelector`, `SizeSelector` to `core/widgets/` for cross-feature reuse.

---

## Functional Requirements

1. **FR-01:** Tạo `lib/features/customizer/` với đủ 3 layer:
   ```
   customizer/
     data/
       datasources/custom_design_datasource.dart (interface)
       datasources/custom_design_datasource_impl.dart
       repositories/custom_design_repository_impl.dart
     domain/
       entities/customization_entity.dart
       repositories/custom_design_repository.dart
       usecases/save_custom_design_usecase.dart
     presentation/
       cubit/customizer_cubit.dart
       cubit/customizer_state.dart
       pages/customizer_page.dart
       widgets/canvas_workspace.dart
       widgets/design_config_panel.dart
       widgets/layer_editor.dart
       widgets/pricing_footer.dart
       widgets/printing_color_picker.dart
   ```

2. **FR-02:** Xóa/move các file khỏi `features/product/`:
   - `product/presentation/cubit/customizer_cubit.dart` → `customizer/presentation/cubit/`
   - `product/presentation/cubit/customizer_state.dart` → `customizer/presentation/cubit/`
   - `product/data/datasources/custom_design_remote_datasource.dart` → `customizer/data/datasources/`
   - `product/data/datasources/custom_design_remote_datasource_impl.dart` → `customizer/data/datasources/`
   - `product/data/repositories/custom_design_repository_impl.dart` → `customizer/data/repositories/`
   - `product/domain/repositories/custom_design_repository.dart` → `customizer/domain/repositories/`
   - `product/domain/entities/customization_entity.dart` → `customizer/domain/entities/`

3. **FR-03:** Tạo `lib/core/constants/printing_constants.dart` với:
   - `heatTransferCost = 30000.0`
   - `reflectiveDecalCost = 50000.0`
   - `extraLayerCost = 10000.0`
   - `heatTransferId = 1`, `reflectiveDecalId = 2`

4. **FR-04:** Refactor `ProductCustomizerPage` (1632 dòng) thành:
   - `customizer_page.dart` — orchestrator, build() ≤ 60 dòng
   - `canvas_workspace.dart` — T-shirt mockup + layer rendering + gesture detection
   - `design_config_panel.dart` — material selector, text editor, font/size controls
   - `layer_editor.dart` — draggable layer list, add/delete controls
   - `pricing_footer.dart` — price breakdown + confirm button
   - `printing_color_picker.dart` — color presets + custom color picker

5. **FR-05:** Update `injection_container.dart`:
   - Import paths từ `features/product/` → `features/customizer/`
   - Giữ nguyên singleton registration strategy

6. **FR-06:** Update `app_router.dart`:
   - Import `CustomizerPage` từ `features/customizer/`
   - BlocProvider scope giữ nguyên

7. **FR-07:** Resolve CartCubit coupling:
   - Truyền `onAddToCart: (variantId, quantity, customDesignId) {}` callback qua constructor
   - Hoặc tạo `AddCustomDesignToCartUseCase` (quyết định trong plan)

8. **FR-08:** Tạo `.claude/agents/flutter-refactorer.md`:
   - Role: di chuyển files, update import paths, extract constants
   - Tools: Read, Grep, Glob, Edit, Write, Bash
   - Output: danh sách files changed + `dart analyze` result
   - Invoke: sau mỗi phase refactor trong `/ck:cook`

9. **FR-09:** Tạo `.claude/agents/flutter-reviewer.md`:
   - Role: review code theo 15 tiêu chí giáo viên + chạy tests
   - Tools: Read, Grep, Glob, Bash
   - Output: verdict (PASS/WARNING/BLOCK) + severity table + `flutter test` result
   - Invoke: phase cuối của `/ck:cook`

---

## Non-Functional Requirements

- **Build safety:** `dart analyze` phải 0 errors sau mỗi phase — không commit code broken
- **No circular deps:** `customizer/` không import `product/`; `product/` không import `customizer/` presentation
- **Backward compat:** SharedPreferences key `'customizations'` giữ nguyên — user không mất data
- **Widget size:** Mỗi widget con ≤ 200 dòng; `build()` của page ≤ 60 dòng

---

## Success Criteria

- [ ] `lib/features/customizer/` tồn tại với đủ 3 layer (data/domain/presentation)
- [ ] `lib/features/product/` không còn file nào chứa từ khóa `customizer` hoặc `custom_design`
- [ ] `customizer_page.dart` build() ≤ 60 dòng (đo bằng wc -l)
- [ ] 5 widget files tồn tại trong `customizer/presentation/widgets/`
- [ ] `core/constants/printing_constants.dart` tồn tại, không còn magic number giá trong page
- [ ] `dart analyze` = 0 errors sau khi hoàn thành
- [ ] `.claude/agents/flutter-refactorer.md` và `.claude/agents/flutter-reviewer.md` tồn tại
- [ ] Existing `product_catalog_bloc_test.dart` vẫn pass sau refactor

---

## Out of Scope

- Di chuyển `ColorSelector`, `SizeSelector`, `ProductCarousel` sang `core/widgets/`
- Viết unit tests mới cho `CustomizerCubit` (chỉ đảm bảo existing tests không vỡ)
- Thay đổi backend API hay pricing logic
- `PrintingColorCubit` (feature `color/`) — giữ nguyên vị trí

---

## Assumptions

- `ProductDetailPage` dùng `CustomizerCubit` chỉ để hiển thị badge — có thể update import path mà không cần refactor logic
- `CartCubit` là singleton trong toàn app — truyền callback là đủ, không cần use case phức tạp
- Flutter SDK và dependencies không thay đổi trong quá trình refactor
