# Phase 2: Revenue API

## Goal

Expose one authorized, range-based source of truth for realized revenue, comparison metrics and zero-filled time-series data.

## Design Constraints

- Endpoint: `GET /api/v1/admin/analytics/revenue-summary?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD`.
- Dates are inclusive business-calendar dates. Convert `[startDate at zone start, endDate + 1 day at zone start)` to UTC/DB `LocalDateTime` boundaries.
- Validate required ISO dates, `startDate <= endDate`, and inclusive span <= 5 years; return HTTP 400 with safe messages.
- Eligibility is current-state snapshot: `paymentCompleted=true`, current status `DELIVERED`, non-null `deliveredAt`, half-open boundary match. Refunded/cancelled/returned states contribute zero.
- Repository returns daily aggregate rows only. Java service zero-fills days and rolls them into daily (<=31 days), ISO weekly (32–180), or calendar monthly (>180) buckets.
- Previous interval has the same inclusive number of days and ends the day before start.
- `growthPercent=null` when previous revenue is zero. Average order value is zero when count is zero.
- Monetary types remain `BigDecimal`; no `double` arithmetic in backend calculations.
- Existing dashboard summary delegates to the same eligibility/range service or removes its revenue field through a compatible deprecation plan; never copy query rules.

## Exact Files and Steps

Backend root: `D:/GitHub/java-ecommerce`.

1. Refactor `src/main/java/com/sport_pro_be/modules/order/repository/OrderRepository.java`:
   - Replace/augment `createdAt` revenue queries with a projection grouped by `deliveredAt` calendar day over explicit half-open bounds.
   - Filter by `paymentCompleted`, `DELIVERED`, and non-null `deliveredAt`.
   - Provide aggregate count/sum query for current and previous intervals, or derive both from daily rows after verifying query cost.
2. Add response records under `modules/analytics/dto/`, including:
   - range echo,
   - `realizedRevenue`, `orderCount`, `averageOrderValue`, `previousPeriodRevenue`, nullable `growthPercent`, grouping,
   - points with `bucketStart`, `bucketEnd`, revenue and order count.
3. Extend `IAnalyticsService.java` and refactor `AnalyticsService.java` into a single authoritative ranged calculation:
   - validate range,
   - resolve timezone boundaries,
   - compute equal previous range,
   - fetch daily aggregates,
   - zero-fill and roll up deterministically,
   - assert/structure code so point sum equals summary revenue.
4. Extend `AnalyticsController.java` and `AnalyticsMessageConstant.java` with the admin endpoint and safe validation errors. Confirm existing Spring Security rules restrict `/api/v1/admin/**` to ADMIN; add method authorization if route configuration is ambiguous.
5. Update `getDashboardSummary()` to call the new service for its default inclusive 7-day range. Preserve unrelated dashboard order/customer metrics and remove its old independent revenue query.
6. Add a composite/partial index migration appropriate to PostgreSQL, likely centered on `delivered_at` with eligibility columns. Confirm exact index through `EXPLAIN (ANALYZE, BUFFERS)` rather than assuming column order.
7. Document response examples and the current-state snapshot/refund semantics near API documentation.

## Tests Planned for Later `ck:test`

- Eligibility matrix: paid+delivered included; unpaid delivered, paid not delivered, cancelled/refunded/returned excluded.
- Timezone boundaries include exact start instant and exclude next-day/end-exclusive instant, including DST-capable test zone even if production zone has no DST.
- Invalid/missing/reversed/>5-year ranges return 400.
- Previous period has exactly equal inclusive calendar days.
- Group thresholds at 31/32 and 180/181 days; ISO week and month clipping; empty buckets return zero.
- Sum of points equals realized revenue and counts; BigDecimal averages/rounding follow declared scale.
- Previous zero yields JSON `growthPercent: null`; nonzero growth is correct.
- Admin authorized; non-admin forbidden.
- Existing dashboard revenue matches ranged endpoint’s default window.
- Repository integration tests against PostgreSQL semantics, not H2-only date casting.

## Build and Quality Gate

- Run backend compile gate and OpenAPI/schema generation if configured.
- Later `ck:test`: repository integration + analytics unit/controller/security tests, followed by relevant backend suite.
- Benchmark production-like 1M-row dataset with `EXPLAIN ANALYZE`; record p95 evidence for a 5-year request.
- Code review must verify authorization, timezone half-open bounds, nullable growth serialization and absence of duplicated revenue rules.
- Run `git diff --check`.

## Success Criteria

- Endpoint returns correct current and previous summaries for any valid <=5-year range.
- Series contains every expected bucket and sums exactly to summary revenue.
- No excluded current status/payment state contributes.
- Dashboard default revenue and ranged endpoint share one service definition.
- Query plan uses the intended index and meets the measured p95 target in a production-like environment.

## Spec Coverage

- P1 custom range and realized revenue.
- FR-05 through FR-11.
- NFR performance, security, timezone and consistency.

## Quality and Testing State

- Quality: APPROVED (verify pass 2026-07-12). Initial gate found 1 HIGH (REV2-QUAL-001, duplicated createdAt revenue rules) + 2 MEDIUM (REV2-QUAL-002 day-count year bound, REV2-QUAL-003 double-precision growth). All three resolved and confirmed in `plans/revenue-range-analytics/quality/phase-02-revenue-api-quality-report.json`. REV2-QUAL-004 (NOTED, EXPLAIN/p95 evidence) remains open and deferred to the later verification pass — non-blocking.
- Testing: not started; cases above are reserved for later `ck:test`.
- Build/performance gate: `mvn compile` passes (exit 0). EXPLAIN ANALYZE/p95 benchmark still outstanding (REV2-QUAL-004).

## Binding Implementation Addendum

- Repository filtering uses UTC half-open instants, but daily grouping must map every timestamp to `LocalDate` through the configured business `ZoneId` in Java, or use a parameterized, tested PostgreSQL `AT TIME ZONE` expression. `delivered_at::date` and implicit/UTC day casts are forbidden.
- Preserve `GET /api/v1/admin/analytics/dashboard-summary` and its existing response fields/types. Its default revenue delegates to the new authoritative range service; unrelated order/customer metrics and old-client parsing remain unchanged.
- The nullable-column/index SQL from Phase 1 is a prerequisite, not an application-startup side effect.
