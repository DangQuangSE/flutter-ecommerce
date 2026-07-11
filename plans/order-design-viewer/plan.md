# Plan: Read-only order design viewer

**Status:** Implementation complete; environment verification blocked

## Scope Challenge

- **Exists:** Customizer canvas, design endpoints, order-detail custom-printing data, and typed routing already exist; the read-only viewer does not.
- **Minimum:** Extend the design read model, add a dedicated viewer Cubit/page, and link both order-detail roles.
- **Complexity:** Hard (three phases and cross-layer integration), but the approved spec removes editing and logo persistence.
- **Testing mode:** Cook performs compile/static build gates and mandatory quality gates. Focused automated tests are handed to `ck:test` immediately after Cook, per pipeline ownership.

## Architecture

The stored rendered front/back preview is the visual truth. Parsed metadata supplies a selectable layer list and property details; artwork is not redrawn and stored coordinates are displayed rather than remapped across devices. A dedicated viewer Cubit owns loading, side, selection, and fallback state. Customer and admin use separate hand-written named `GoRoute` entries with fixed roles/endpoints. Original logo persistence is out of scope.

## Phases

1. [Data and domain](phase-01-data-domain.md) — retain the complete viewer payload and load it through role-correct APIs.
2. [Viewer UI](phase-02-viewer-ui.md) — implement the full-screen, read-only preview and metadata inspector.
3. [Routing and integration](phase-03-routing-integration.md) — expose separate admin/customer routes and order-detail entry points.

## Risks

- Legacy or malformed metadata must degrade to preview-only state without throwing.
- Local logo paths may be unavailable on another device; show availability only and never depend on them for the visual preview.
- Reusing editable customizer widgets must not expose mutation callbacks; extract only safe presentation primitives where practical.

## Verification and Completion

Session 2026-07-12: All three phases are implemented and independently semantic-quality approved after six findings were remediated. Flutter analyzer remained silent/hung after process restart. Receipt generation was also blocked because local `python.exe` could not start. Automated tests were not run by Cook.

Every phase must pass its relevant `dart analyze` compile/static gate and mandatory `ck:quality --gate` before completion. After Cook, `ck:test` owns focused unit/widget tests for endpoint choice, parser fallback, read-only selection, role-specific actions, navigation, and responsive layout.
