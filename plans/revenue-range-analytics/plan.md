# Plan: Revenue analytics by custom date range

## Status

- Mode: Hard
- Source: `plans/revenue-range-analytics/spec.md`
- Implementation: not started
- Testing: deferred to a later `ck:test`, but test design and mandatory build/quality gates are part of every phase

## Scope Challenge

- Exists: partial. Backend has daily revenue/dashboard endpoints and Flutter has a dashboard summary, but both use the wrong revenue lifecycle and fixed dates.
- Minimum: introduce authoritative payment/delivery timestamps and one revenue service, expose a ranged endpoint, consume it from a dedicated Flutter feature, and audit legacy rows.
- Complexity: Hard. This crosses persistence, VNPay/COD transitions, authorization, timezone boundaries, aggregation, stale asynchronous UI state, and production data migration.

## Spec Quality Check

- Clarifications: none blocking.
- Success criteria: measurable.
- Priorities: P1/P2 identified; P3 explicitly out of scope.
- Acceptance criteria: testable.
- Verdict: PASS.

## Architecture Decisions

1. Keep `LocalDateTime` in the current entity model. Store/interpret persisted timestamps in UTC and resolve API calendar dates through one configured business `ZoneId`; never use the JVM default timezone implicitly.
2. Centralize order transition invariants in one transactional domain/service path. VNPay callback and admin delivery updates must be idempotent and preserve the first valid `paidAt`/`deliveredAt`.
3. Query eligible orders as daily aggregates in PostgreSQL, then roll daily rows into daily/weekly/monthly buckets in Java. This keeps timezone filtering/index use explicit and guarantees zero-filled deterministic buckets.
4. Analytics is a current-state, net-like snapshot: an order contributes only while it is currently `DELIVERED` and payment-complete. A later refund/return removes it from any queried historical range. Accounting ledgers and refund-event attribution remain out of scope.
5. `growthPercent` is nullable when previous-period revenue is zero; the API and Flutter must not invent infinity or 100%.
6. Flutter uses a dedicated `RevenueAnalyticsCubit`, separate from the existing admin/dashboard BLoC. Each request receives a monotonically increasing token so late responses cannot overwrite a newer range.
7. No automatic legacy inference. Migration SQL first reports candidates and only mutates rows supported by auditable payment evidence; ambiguous rows remain unchanged.

## Delivery Phases

1. [Order payment lifecycle](phase-01-order-payment-lifecycle.md): schema, timezone contract, centralized/idempotent VNPay and COD transitions.
2. [Revenue API](phase-02-revenue-api.md): eligibility query, range validation, comparison and series response, dashboard delegation.
3. [Flutter dashboard](phase-03-flutter-dashboard.md): typed clean-architecture flow, range presets/picker, chart/summary UI, refresh and stale-request protection.
4. [Legacy migration and verification](phase-04-legacy-migration-verification.md): audited migration, indexes, data reconciliation and end-to-end release gates.

## Cross-Phase Risks

- Existing timestamp column semantics may depend on database/JDBC timezone. Verify configuration before migration; do not reinterpret old values silently.
- VNPay may have redirect and IPN paths. Only the verified server-side transaction path may mark payment successful; both paths must converge on the same idempotent operation.
- Current-state snapshots change historical reports after refunds. UI wording must say “doanh thu thực nhận hiện tại” rather than implying an immutable accounting ledger.
- Weekly buckets require a declared convention. Use ISO Monday-start weeks, clipped to the selected interval, and return explicit bucket start/end dates.
- A 1M-order/5-year p95 target requires an execution-plan check using production-like cardinality; unit tests alone cannot establish it.

## Global Verification Gates

Each phase must pass before the next is declared complete:

1. Relevant formatter and static analyzer/build command exits 0 and its output is read.
2. Targeted automated tests designed in the phase are executed by the later `ck:test` workflow; until then status remains “not started,” never “passed.”
3. `ck:quality --gate` (or equivalent code-review verification) reports no blocker/high unresolved finding.
4. `git diff --check` is clean and unrelated user changes are preserved.
5. Phase success criteria and mapped FRs are checked explicitly.

## Spec Coverage

- Phase 1: P1 payment consistency; FR-01–FR-04; timezone, consistency and idempotency NFRs.
- Phase 2: P1 range/revenue correctness; FR-05–FR-11; performance and authorization NFRs.
- Phase 3: P1/P2 admin experience; FR-12–FR-14.
- Phase 4: FR-15 and all cross-system success criteria/release evidence.

## Cook Handoff

Cook phases in order. Production migrations are authored and reviewed during cook but must not be executed against a shared/production database without an explicit operator approval and backup. Recommended execution after approval:

`/ck:cook --hard plans/revenue-range-analytics/plan.md`

## Red-Team Resolution (Binding)

- Revenue calendar days are derived in `app.business-zone` from UTC instants. `delivered_at::date`, UTC date casts, and implicit database/JVM timezone grouping are prohibited.
- Rollout is schema-first: operator applies reviewed nullable-column SQL before deploying code; Hibernate `ddl-auto` is not a deployment migration.
- Every payment/delivery/return mutation uses one `@Transactional` coordinator and repository `PESSIMISTIC_WRITE` lookup. Verified IPN uses injected server `Clock` for first `paidAt`.
- Spending/tier credit and return/refund reversal share that locked coordinator and explicit idempotency guards; duplicate events cannot repeat financial/loyalty side effects.
- `/api/v1/admin/analytics/dashboard-summary` remains path/field/type compatible and delegates revenue only; staged/older Flutter clients continue to work.
- Flutter ownership is exact: `admin_module.dart` registers the use case/Cubit factory, `AdminDashboardPage` provides and initially loads it, and `AdminDashboardTab` only renders it. Page tab re-entry plus a successful-order-update invalidation revision is the sole refresh trigger; builds never fetch.
- Phase 4 Cook work is artifact authoring and static quality only. Tests, E2E, migration execution/rehearsal, Docker smoke and performance measurements are post-Cook.
