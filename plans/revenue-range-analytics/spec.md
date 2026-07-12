# Spec: Revenue analytics by custom date range

**Date:** 2026-07-12
**Status:** Ready

---

## Problem Statement

Dashboard hiện gọi giá trị “Doanh thu” nhưng backend chỉ tính đơn `DELIVERED` theo `createdAt` trong 7 ngày gần nhất. Admin cần doanh thu thực nhận chính xác theo khoảng thời gian tùy chọn và dashboard phải tự cập nhật khi trạng thái đơn thay đổi.

---

## User Stories

- **[P1]** As an admin, I want to select a date range so that I can analyze realized revenue for any accounting period.
  Accepted when: selecting valid start/end dates reloads summary and series using that inclusive date range.

- **[P1]** As an admin, I want revenue to include only paid and delivered orders so that unpaid, cancelled, and refunded orders are excluded.
  Accepted when: only orders with `paymentCompleted=true`, `status=DELIVERED`, and `deliveredAt` inside the range contribute to realized revenue.

- **[P1]** As an admin, I want COD/VNPay payment state to be updated consistently so that valid delivered orders are not missing from analytics.
  Accepted when: VNPay IPN success sets payment completion time; COD delivery sets payment completion and delivery time atomically.

- **[P2]** As an admin, I want quick presets so that common 7-day, 30-day, current-month, and current-year reports require one tap.
  Accepted when: each preset produces deterministic inclusive dates in the configured business timezone.

- **[P3]** _(out of scope — accounting exports, taxes, platform fees, partial refunds, and multi-currency conversion)_

---

## Functional Requirements

1. FR-01: Add nullable `paidAt` and `deliveredAt` timestamps to `Order`; set them through payment and fulfillment transitions, never from client input.
2. FR-02: VNPay verified/IPN success sets `paymentCompleted=true` and `paidAt` once; repeated callbacks remain idempotent.
3. FR-03: Transitioning a COD order to `DELIVERED` atomically sets `paymentCompleted=true`, `paidAt`, and `deliveredAt`. Transitioning a prepaid order to `DELIVERED` sets `deliveredAt` without overwriting `paidAt`.
4. FR-04: Reject or flag `DELIVERED` transitions for online-payment orders that are not payment-complete.
5. FR-05: Add an admin analytics endpoint accepting required ISO dates: `GET /api/v1/admin/analytics/revenue-summary?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD`.
6. FR-06: Validate `startDate <= endDate` and limit ranges to 5 years; invalid requests return HTTP 400 with a user-safe message.
7. FR-07: Revenue query includes only `paymentCompleted=true`, `status=DELIVERED`, and `deliveredAt` within the inclusive business-timezone boundaries. `REFUNDED`, cancelled, returned, and unpaid orders contribute zero.
8. FR-08: Response includes `realizedRevenue`, `orderCount`, `averageOrderValue`, `previousPeriodRevenue`, `growthPercent`, `startDate`, `endDate`, and time-series points.
9. FR-09: Previous period has the same inclusive number of days and ends one day before `startDate`.
10. FR-10: Time-series grouping is daily for ranges up to 31 days, weekly for 32–180 days, and monthly above 180 days; missing buckets return zero.
11. FR-11: Existing dashboard summary either delegates to the new service with its default 7-day range or is deprecated without duplicating revenue rules.
12. FR-12: Flutter models the range/summary with typed entities and loads it through repository/use-case/BLoC layers.
13. FR-13: Dashboard provides presets for 7 days, 30 days, current month, current year, plus a date-range picker; selected dates and label are always visible.
14. FR-14: Dashboard refreshes when opened/revisited and after admin order status updates.
15. FR-15: Add a reviewed one-time migration for legacy paid/delivered data. It must report affected rows before mutation and must not infer online payment success solely from `DELIVERED` without an auditable payment record.

---

## Non-Functional Requirements

- Performance: revenue endpoint p95 below 500 ms for a 5-year range with 1 million orders; add an index supporting status/payment/delivered-time filtering.
- Security: endpoint requires ADMIN authorization; timestamps and revenue eligibility cannot be supplied by the Flutter client.
- Consistency: payment/delivery timestamp writes occur in the same transaction as their corresponding state changes.
- Timezone: date boundaries use one configured business timezone; API dates are calendar dates and response echoes the resolved range.
- Reliability: VNPay callbacks and repeated delivery updates are idempotent and do not change the original timestamps.

---

## Success Criteria

- [ ] Eligibility matrix: 100% of paid/delivered, unpaid/delivered, paid/not-delivered, cancelled, and refunded cases return expected revenue.
- [ ] Boundary accuracy: orders exactly at start-of-day and end-of-day are included once in the configured timezone.
- [ ] Comparison accuracy: previous-period range contains exactly the same number of calendar days.
- [ ] Series integrity: sum of returned buckets equals `realizedRevenue` for every supported grouping.
- [ ] Payment consistency: VNPay and COD happy paths persist correct `paidAt`/`deliveredAt`; duplicate events are idempotent.
- [ ] Flutter behavior: all presets and custom ranges call the endpoint with correct dates and display returned totals.
- [ ] Refresh behavior: returning to dashboard after an eligible delivery triggers one fresh analytics load.

---

## Out of Scope

- Gross merchandise value and abandoned-cart analytics.
- Platform fees, shipping settlements, taxes, profit, and cost of goods sold.
- Partial refunds and revenue adjustments by refund date.
- CSV/Excel/PDF export.
- Multiple currencies or store-specific timezones.

---

## Assumptions

- The application uses one business timezone configured by backend deployment.
- Full refunds change order status to `REFUNDED`, removing the order from realized revenue.
- Existing online payment transaction/reference data can be audited before any legacy migration marks an order paid.

