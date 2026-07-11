# Spec: Read-only order design viewer

**Date:** 2026-07-11
**Status:** Ready

---

## Problem Statement

Order detail hiện chỉ cho biết đơn có custom printing và phí in, nhưng user/admin không thể kiểm tra trực quan bản thiết kế hoặc từng layer. Cần một viewer giống customizer ở chế độ chỉ đọc để đối chiếu thiết kế trước khi sản xuất.

---

## User Stories

- **[P1]** As an admin, I want to open a custom design from order detail so that I can verify it before production.
  Accepted when: tapping the custom-printing row opens a full-screen viewer for the correct `customDesignId`.

- **[P1]** As a customer, I want to inspect the design attached to my order so that I can confirm what I submitted.
  Accepted when: the customer can open only a design returned through the ownership-protected customer endpoint.

- **[P1]** As a viewer, I want to switch sides and inspect layers so that I can understand every stored component.
  Accepted when: front/back switching, zooming, layer selection, and text/font/color/size/position details work without any mutation controls.

- **[P2]** As an admin, I want to open the front/back preview URLs so that I can download production references.
  Accepted when: available front/back preview actions open their corresponding remote URLs and unavailable sides are disabled or hidden.

- **[P3]** _(out of scope — upload, persist, reconstruct, and download each original logo asset)_

---

## Functional Requirements

1. FR-01: Add role-fixed named routes to `DesignViewerPage` with `customDesignId`; route builders choose customer/admin mode without user-controlled role input.
2. FR-02: User order detail and admin order detail expose a clear action on custom-printing items to open the viewer.
3. FR-03: Customer loading uses `GET /api/custom-designs/{id}`; admin loading uses `GET /api/admin/custom-designs/{id}`.
4. FR-04: Extend the Flutter design entity/model to retain front/back preview URLs, front/back metadata, material information, counts, and printing price.
5. FR-05: Reuse customizer design language and passive presentation primitives where compatible, while using a dedicated immutable preview viewport that exposes no editor callbacks or persistence.
6. FR-06: Viewer supports front/back switching, zoom/pan of the rendered preview, and layer selection from a synchronized layer list/details panel.
7. FR-07: Text layer details include side, content, font, color, font size, and stored coordinates.
8. FR-08: Logo layer details include side, stored coordinates, and asset availability. Missing local logo files must not crash rendering.
9. FR-09: When metadata is absent or malformed, show the rendered preview and a user-facing limited-detail warning.
10. FR-10: Admin-only actions open available front/back preview URLs; customer viewer has no download action.
11. FR-11: Viewer must never mutate Cubit state, local persistence, backend design data, or order data.

---

## Non-Functional Requirements

- Performance: show a loading state immediately and render the first available preview within 2 seconds after a successful API response on a normal connection.
- Security: customer access remains ownership-checked; admin access uses the admin endpoint and existing authorization token.
- Reliability: 100% of null, empty, malformed, or legacy metadata cases render preview/fallback instead of throwing an uncaught exception.
- Layout: no overflow at 360×640 and 428×926 logical-pixel viewports.
- Maintainability: preview/inspection code remains independent from editable CustomizerCubit state, while shared passive controls/styles are reused where compatible.

---

## Success Criteria

- [ ] Entry points: custom designs open from both user and admin order details.
- [ ] Read-only safety: 0 add/edit/move/resize/delete/save operations are available or triggered in viewer mode.
- [ ] Layer inspection: all parseable front/back layers appear in the layer list and can be selected without relying on device-dependent canvas coordinates.
- [ ] Fallback safety: malformed metadata and missing logo files produce 0 crashes in automated tests.
- [ ] Authorization: user and admin viewer requests use their correct endpoints in 100% of repository tests.
- [ ] Admin preview: front/back URL actions map to the correct stored preview in widget tests.
- [ ] Static quality: `dart analyze` reports 0 new errors or warnings and focused tests pass.

---

## Out of Scope

- Uploading each logo layer to durable remote storage.
- Recovering logo source files referenced only by legacy local paths.
- Editing, duplicating, or reordering layers from order detail.
- Rotation and arbitrary logo dimensions until those fields are persisted in metadata.
- Guaranteed direct save into Android/iOS photo libraries; MVP opens remote preview URLs.
- Changing order price calculations.

---

## Assumptions

- Backend continues returning `designImageUrl`, `backDesignImageUrl`, `designMetadata`, and `backDesignMetadata` from both design-detail endpoints.
- Rendered preview URLs remain accessible to authenticated app users through the current Cloudinary configuration.
- Existing metadata JSON remains compatible with `DesignLayer.fromJson` for parseable designs.
