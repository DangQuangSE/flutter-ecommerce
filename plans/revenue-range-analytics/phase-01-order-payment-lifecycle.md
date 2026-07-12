# Phase 1: Order payment lifecycle

## Goal

Make payment and delivery timestamps authoritative, transactional, timezone-safe and idempotent before any analytics query depends on them.

## Design Constraints

Preflight: Backend conventions use Spring `@Service`/constructor injection, transactional service methods, JPA repositories, `BadRequestException`/`ResourceNotFoundException`, and SQL deployment artifacts under `docs/sql/`. Phase boundary is the Java backend only; preserve VNPay IPN response codes and existing DTO contracts. Apply pessimistic locking through a dedicated repository lookup, inject `Clock`/validated business `ZoneId`, and do not execute migrations or add/run tests during Cook. Existing in-progress edits to `Order`, `OrderRepository`, `common.properties`, and the timestamp SQL are resumed and preserved.

- Retain `LocalDateTime`; define UTC persistence/JDBC behavior explicitly and use a configured business `ZoneId` only for calendar boundaries.
- `paidAt` and `deliveredAt` are server-controlled and nullable. DTO requests must not bind them.
- All status/payment writes pass through one transition service/method with explicit invariants; do not duplicate mutations across controller, VNPay and admin order services.
- VNPay success is accepted only after existing signature/transaction verification. Duplicate success callbacks preserve the original `paidAt`.
- COD `DELIVERED` atomically sets `paymentCompleted=true`, `paidAt` and `deliveredAt`; repeated delivery preserves timestamps.
- Prepaid delivery requires payment completion and sets only missing `deliveredAt`. Unpaid online delivery returns a domain-safe 4xx error.
- Regressions to cancelled/refunded/returned states do not rewrite historical timestamps; analytics eligibility is based on current state.

## Exact Files and Steps

Backend root: `D:/GitHub/java-ecommerce`.

1. Inspect and update configuration:
   - `src/main/resources/application.properties` and environment/profile variants.
   - Add a named property such as `app.business-zone=Asia/Ho_Chi_Minh`; configure Hibernate/JDBC UTC consistently.
   - Add a small configuration bean/value object under `src/main/java/com/sport_pro_be/config/` so services inject a validated `ZoneId` and `Clock` rather than calling `now()` directly.
2. Extend `src/main/java/com/sport_pro_be/modules/order/domain/Order.java` with nullable `paidAt` and `deliveredAt`, appropriate column/index metadata, and no public client-controlled setters beyond the domain transition boundary.
3. Add a reviewed schema migration in the project’s established migration mechanism. If none exists, create an audited SQL file under `docs/sql/` for the new nullable columns; do not rely solely on `ddl-auto=update` for deployment.
4. Inspect `OrderStatus`, `PaymentMethod`, `OrderService.java`, admin status update controller/DTOs, and VNPay service/controller paths. Introduce one transactional transition coordinator (prefer the order service/domain package) that owns:
   - verified payment success,
   - COD delivery,
   - prepaid delivery,
   - repeated-event idempotency,
   - invalid transition rejection.
5. Route VNPay IPN/verified callback through the coordinator. Preserve existing response semantics required by VNPay, but ensure database commit and duplicate handling are deterministic.
6. Route admin `DELIVERED` updates through the same coordinator. Avoid a read-modify-write split across transactions.
7. Extend response mapping only if operational/admin screens need `paidAt`/`deliveredAt`; never add them to write request models.
8. Add focused repository locking/optimistic versioning if concurrent callback and delivery updates can otherwise lose timestamps; document the chosen concurrency control.

## Tests Planned for Later `ck:test`

- VNPay verified success sets completion and `paidAt`; duplicate callback preserves exact timestamp.
- Invalid signature/failure callback changes nothing.
- COD delivery atomically sets completion, `paidAt`, and `deliveredAt`; duplicate delivery preserves timestamps.
- Paid prepaid delivery sets `deliveredAt` without changing `paidAt`.
- Unpaid prepaid delivery is rejected and order remains unchanged.
- Concurrent duplicate events cannot lose or advance timestamps.
- Configured `Clock`/zone makes tests deterministic.

## Build and Quality Gate

- Run backend formatter/checkstyle if configured, then `mvn -DskipTests compile` (or wrapper equivalent).
- Later `ck:test`: execute focused order/VNPay service tests, then relevant backend suite.
- Run code review with special attention to transaction boundaries, callback authentication, concurrency and client write exposure.
- Run `git diff --check` in the backend repo.

## Success Criteria

- Every valid payment/delivery path persists invariant-consistent timestamps in one transaction.
- Duplicate callbacks/status updates are true no-ops for original timestamps.
- Online unpaid orders cannot become revenue-eligible through a delivery-only update.
- UTC persistence and configured business timezone are explicit and testable.
- No request DTO permits clients to supply analytics timestamps.

## Spec Coverage

- P1 payment consistency.
- FR-01, FR-02, FR-03, FR-04.
- NFR consistency, reliability, timezone and security foundations.

## Quality and Testing State

- Quality: not evaluated.
- Testing: not started; cases above are reserved for later `ck:test`.
- Build gate: not run.

## Binding Implementation Addendum

1. First author `D:/GitHub/java-ecommerce/docs/sql/add_order_revenue_timestamps.sql` with nullable `paid_at`/`delivered_at`, guards and rollout notes. Required order is backup -> apply schema SQL -> deploy application; never rely on `ddl-auto=update`.
2. Add `OrderRepository.findByIdForUpdate` with `@Lock(PESSIMISTIC_WRITE)`. A single `@Transactional` transition coordinator must use it for verified payment, delivery, cancellation, return and refund mutations; no read-modify-write split is allowed.
3. Only a signature/provider-verified server IPN may mark VNPay paid. Set the first `paidAt` from injected server `Clock.instant()` converted using the explicit persistence convention; never trust client/provider query time. Duplicate callbacks preserve it.
4. COD delivery and prepaid delivery run under the same lock. Move existing customer spending and loyalty-tier credit into the coordinator and add/use a persisted idempotency guard. Return/refund reversal also runs there with its own guard, so retries cannot double-credit, double-debit or repeat tier evaluation.
5. Calendar configuration injects both validated business `ZoneId` and `Clock`; no direct `now()` or default timezone is permitted.
