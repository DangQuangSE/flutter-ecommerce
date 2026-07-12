# Plan: Simplified admin dashboard statistics

**Mode:** Fast  
**Source:** `plans/admin-dashboard-simplification/spec.md`  
**Phases:** 1

## Scope Challenge

- **Exists:** The dashboard already renders the Revenue, Orders, and New Customers cards, date presets, custom range picker, loading/error states, and daily revenue rows.
- **Minimum:** Reshape the existing dashboard widget only: retain the three cards, replace the preset chips with one filter action and bottom sheet, and remove daily rows.
- **Complexity:** Fast. This is a focused presentation change using the existing analytics cubit and date-range API.
- **Test mode:** Default (not TDD).

## Spec Quality Check

- No unresolved clarification markers.
- Success criteria are measurable.
- User stories are prioritized P1/P2/P3.
- Acceptance criteria are testable.

**Verdict:** PASS

## Phase Summary

| Phase | Outcome | Status |
|---|---|---|
| [01 — Simplify dashboard](phase-01-simplify-dashboard.md) | Three KPI cards remain; one shared period action replaces visible presets; daily rows are removed | Implemented; verification tooling blocked |

## Scope Boundary

- No backend or endpoint changes.
- No chart, export, drill-down, or configurable widget work.
- No redesign of the existing Revenue, Orders, or New Customers cards.
- No changes to admin authorization, navigation, chat, or notifications.

## Risks

- The existing Revenue analytics response supplies filtered revenue and order count; New Customers remains on the existing admin stats source. Do not invent a second period model or endpoint.
- Custom date selection can be cancelled; cancellation must leave the current data and active range unchanged.
- Existing previous data must remain visible while a refresh is loading or fails.

## Handoff

Ready to cook:

`/ck:cook --fast plans/admin-dashboard-simplification/plan.md`
