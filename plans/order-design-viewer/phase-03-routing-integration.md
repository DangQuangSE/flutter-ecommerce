# Phase 03: Routing and integration

**Status:** Implemented; semantic quality approved, analyzer unverified

## Design Constraints

Preflight: Follow existing hand-written nested named GoRoute, GetIt BlocProvider, path-parameter parsing, and order-card navigation conventions; role is fixed by route builder.

- Use separate hand-written named `GoRoute` entries consistent with this repository; each route builder fixes the role so endpoint authorization cannot be selected by query input.
- Pass only `customDesignId` and the fixed route mode; load authoritative design data after navigation.
- Entry points appear only for order items with a valid custom design.
- Do not change order pricing or order mutation behavior.

## Quality and Testing State

- **Quality:** Not evaluated.
- **Testing:** Not started; `ck:test` handoff cases cover both entry points, route ID parsing, fixed roles, back navigation, and admin/customer action visibility.
- **Build gate:** full `dart analyze` after router and order-detail integration.

## Steps

1. Add `AppRoutes` name/path constants with `:id` parameters and two `app_router.dart` builders: customer route under the authenticated customer area and admin route under the admin area/redirect convention. Each provides `DesignViewerCubit` with a compile-time-fixed `DesignViewerRole`.
2. Update `order_detail_item_card.dart` and its page callback chain with an `AppStrings` “Xem thiết kế” action navigating to the customer named route using the correct `customDesignId`.
3. Update `admin_order_detail_page.dart` item card with the equivalent action navigating to the fixed admin named route.
4. Confirm navigation/back behavior, unavailable-ID guards, loading/error copy, and role-specific preview actions are consistent with existing UI conventions.
5. Run the full analyze build gate, then mandatory quality gate; record exact `ck:test` scenarios for the post-Cook testing handoff.

## Success Criteria

- Customer and admin can open the correct design from their respective order details.
- Each route always invokes its role-correct endpoint.
- Customer UI has no admin preview-opening actions.
- Existing order status, cancellation, and pricing flows remain untouched.
- Full analyze passes and `ck:quality --gate` approves all integration files.

## Spec Coverage

- P1 admin/customer entry points; P2 admin preview access.
- FR-01, FR-02, FR-03, FR-10, FR-11.
- Authorization and static-quality success criteria (verification deferred).
