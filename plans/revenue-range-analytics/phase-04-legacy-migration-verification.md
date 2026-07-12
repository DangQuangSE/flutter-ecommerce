# Phase 4: Legacy migration and verification

## Goal

Safely reconcile only auditable legacy rows, validate the complete backend–Flutter behavior, and produce release evidence without guessing payment history.

## Design Constraints

- Never infer successful online payment solely from `status=DELIVERED`, payment method text, or UI appearance.
- Migration is operator-run, transactional, idempotent and audited. It must report candidates and ambiguous rows before mutation.
- Require a database backup and explicit environment/operator approval before executing mutations outside a disposable local database.
- Online rows may be updated only when a verified payment transaction/reference record proves success. COD delivered rows may be handled under the documented business invariant only after stakeholder approval; list them separately rather than silently updating.
- Preserve original evidence and timestamps. If no trustworthy paid/delivery instant exists, leave nullable and report for manual reconciliation.
- Migration verification compares pre/post row counts, sums and sampled IDs, and supports rollback/restoration instructions.
- Automated test execution belongs to the later `ck:test`, but release cannot be claimed until all planned suites and build/quality gates pass.

## Exact Files and Steps

1. Inspect backend payment transaction tables/entities and actual legacy data shape. Document which columns constitute auditable VNPay success (transaction reference, verified response code, provider timestamp, uniqueness).
2. Create `D:/GitHub/java-ecommerce/docs/sql/migrate_legacy_order_payment_delivery_timestamps.sql` containing clearly separated sections:
   - read-only inventory/counts by status/payment method/completion/timestamp state,
   - auditable candidate detail rows,
   - ambiguous rows report,
   - guarded transactional updates for approved evidence classes,
   - post-update assertions and reconciliation queries,
   - rollback guidance or backup restore reference.
3. Make mutations idempotent (`... IS NULL`, evidence joins, explicit expected-count guards). Abort transaction if evidence uniqueness or row-count assumptions fail.
4. Do not execute the mutation automatically through Docker startup, Hibernate, or application boot. Add deployment notes identifying when and how an operator runs it.
5. On a disposable copy/local database:
   - take a logical backup,
   - run report-only section,
   - review candidate IDs,
   - run mutation with explicit approval,
   - run postchecks twice to demonstrate idempotency.
6. Rebuild/restart backend only as required for schema/application changes; verify health and authenticated endpoint behavior.
7. Perform end-to-end scenarios for VNPay, COD, invalid prepaid delivery, duplicate events, refund removal, range boundaries and Flutter refresh.
8. Capture performance evidence for the 5-year range and query plan; capture API contract samples for zero/nonzero previous revenue.
9. Update `plan.md`/phase statuses only from command output and observed evidence. Record unrelated pre-existing failures separately and do not label the feature complete if a required gate is blocked.

## Tests Planned for Later `ck:test`

- Execute all Phase 1 backend lifecycle tests.
- Execute all Phase 2 repository/service/controller/security tests.
- Execute all Phase 3 Flutter model/Cubit/widget/navigation tests.
- Migration fixture tests: auditable VNPay updated; ambiguous delivered online untouched; guarded COD policy; already-migrated rows unchanged; duplicate evidence aborts; second run changes zero rows.
- End-to-end API/UI smoke scenarios with fixed business timezone and boundary timestamps.
- Regression tests for existing dashboard order/customer metrics and existing order/payment flows.

## Build and Quality Gate

- Backend: formatter/checkstyle, compile/package, focused suites, then full relevant Maven suite.
- Flutter: format check, `flutter analyze`, targeted tests, relevant suite, debug build.
- Database: migration dry run, backup confirmation, post-migration reconciliation, index/query-plan evidence.
- Run final `ck:quality --gate`/code review across both repositories and resolve every blocker/high issue.
- Run `git diff --check` in both repositories and inspect final diffs for secrets or unrelated changes.

## Success Criteria

- No legacy row is marked paid without documented evidence/policy and an audit trail.
- Migration is guarded, repeatable, and verified on a disposable database before any shared environment.
- Eligibility, boundaries, comparison, series sum, payment idempotency, presets and refresh meet every spec success criterion.
- Backend and Flutter mandatory builds/analyzers pass with recorded output.
- Required automated suites pass under later `ck:test`; until then the overall feature remains implemented-but-unverified.
- Production-like query evidence supports p95 <500 ms or the feature is not released until remediated.

## Spec Coverage

- FR-15.
- All Success Criteria and cross-cutting NFR verification.
- Confirms P1/P2 behavior end to end without expanding P3 out-of-scope accounting features.

## Quality and Testing State

- Quality: `ck:quality --gate` approved 2026-07-12 (report: `quality/phase-04-legacy-migration-verification-quality-report.json`; no receipt issued — the receipt fingerprint mechanism requires report and reviewed files to share one git repo root, but this phase's artifacts live in `java-ecommerce` while the plan lives in `flutter-ecommerce`, same as phases 1-2). Zero findings: report-then-mutate ordering, evidence-gated idempotent UPDATE, expected-row-count guard, reconciliation checks, and rollback/backup guidance all verified present in `docs/sql/migrate_legacy_order_payment_delivery_timestamps.sql` and `docs/revenue-analytics-rollout.md`.
- Testing: not started; execution reserved for later `ck:test`.
- Migration: not executed (artifact authoring and static review only, per Binding Cook Scope Override).
- Release gate: blocked until migration rehearsal, E2E scenarios, and p95/query-plan evidence exist — all explicitly post-Cook.

## Binding Cook Scope Override

Phase 4 in `ck:cook` only authors and statically reviews:

- guarded/idempotent migration SQL and report-only queries;
- `docs/revenue-analytics-rollout.md` covering backup, schema-first deploy, candidate approval, mutation, repeat postchecks, rollback and old-endpoint compatibility;
- post-Cook command/checklists for API smoke, E2E, disposable migration rehearsal and `EXPLAIN (ANALYZE, BUFFERS)`.

Cook must not run tests, database migration/dry-run, Docker/API E2E, production-like benchmark or performance measurement. Its gates are formatter, compile/analyzer, static SQL review, `ck:quality --gate`, and `git diff --check`. All automated tests, E2E, migration execution/rehearsal and p95/query-plan evidence are explicitly post-Cook via `/ck:test` and operator-approved release verification. Phase completion means artifacts authored and statically quality-approved, not release verification passed.
