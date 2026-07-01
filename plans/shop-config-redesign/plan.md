# Plan: Admin Shop Config Page Redesign

**Spec:** plans/shop-config-redesign/spec.md
**Mode:** Hard
**Status:** Ready to cook
**Date:** 2026-07-02

---

## Overview

Redesign the admin shop configuration page to:
1. Remove `rating` and `ratingCount` from editable form (backend computes them)
2. Replace URL text inputs with image pickers that upload to Cloudinary via backend
3. Redesign layout to profile-card style (cover + avatar + scrollable fields)

---

## Phases

| # | Phase | Files | Risk |
|---|-------|-------|------|
| 1 | Backend: upload endpoint + remove rating fields | AdminShopController, UpdateShopRequest, ShopServiceImpl | Low |
| 2 | Flutter data layer: uploadShopImage | datasource, repository | Low |
| 3 | Flutter cubit: upload states + method | shop_cubit, shop_state | Low |
| 4 | Flutter UI: full layout redesign | admin_shop_config_page, new picker widgets, app_strings | Medium |

---

## Risks

- `image_picker` package may not be in pubspec.yaml — check and add if missing
- Stack + Positioned for avatar overlap requires `clipBehavior: Clip.none` to avoid avatar being clipped by cover's bottom edge
- Backend `UpdateShopRequest` removing fields is a breaking change if other clients send those fields — safe since we control both
