# Brainstorm: Professional Flutter E-Commerce Folder Structure

**Date:** 2026-05-31

## Ideas Explored

- **Clean Architecture (full)** — strict domain/data/presentation separation at top level. Dismissed as over-engineered for a single-team MVP.
- **Feature-first flat** — all files per feature in one folder, no layering. Simple but doesn't scale past 3 features.
- **Feature-first + Clean Architecture per feature** — chosen. Each feature owns its own data/domain/presentation layers. Scales well, testable, team-parallel.
- **MVVM + BLoC** — considered, but MVVM ViewModel role is absorbed by BLoC in Flutter ecosystem. Redundant layer.
- **GetX monolith** — rejected. Poor testability, tight coupling, not appropriate for production MVP.

## User's Direction

Feature-first modular structure with Clean Architecture within each feature. BLoC for complex features (auth, product, checkout), Cubit for simpler ones (cart, profile). GoRouter for navigation, Dio for networking, get_it for DI.

## Features Identified (MVP scope)

- `auth` — login, register, token management
- `product` — listing, detail, search, filter
- `cart` — add/remove, quantity, local persistence
- `checkout` — address, payment method, order placement
- `order` — order history, order detail
- `profile` — user info, settings

## Open Questions

- Backend: REST API or Firebase? Affects datasource impl strategy.
- Auth: JWT token refresh strategy — how to handle expiry?
- Payment: real payment gateway (Stripe/VNPay) or mock for MVP?

## Risks

1. BLoC boilerplate can slow initial development — mitigate with Cubit where state is simple
2. GoRouter + nested navigation in e-commerce flows (checkout funnel) needs careful route design upfront
3. No backend decided yet — datasource layer may need rework when API is finalized
