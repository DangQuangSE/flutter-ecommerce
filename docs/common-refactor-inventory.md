# Common Refactor Inventory

Baseline for building shared UI primitives conservatively across the Flutter app.

## Module Coverage

| Group | Modules |
| --- | --- |
| Admin/catalog | `admin`, `brand`, `category`, `color`, `coupon`, `size`, `shop`, `setting` |
| Commerce | `product`, `cart`, `checkout`, `payment`, `order`, `review` |
| User/support | `auth`, `profile`, `address`, `notification`, `chat`, `location`, `customizer` |

## Current Hotspots

| Feature | Dart files | Files >= 250 lines | Notes |
| --- | ---: | ---: | --- |
| `admin` | 103 | 12 | Highest-priority module; many admin product/order widgets and pages still need decomposition. |
| `auth` | 49 | 5 | Large login/register/OTP pages; repeated form, loading, snackbar, and validation patterns. |
| `product` | 59 | 4 | Catalog/detail/home widgets repeat loading, empty, image, and filter UI. |
| `checkout` | 34 | 3 | Address/coupon/payment selectors repeat cards, sheets, and form shells. |
| `customizer` | 30 | 3 | Tool panels repeat section headers, sliders, toggles, and image upload feedback. |
| `color` | 23 | 3 | Management sheets repeat form and dialog patterns. |
| `brand`, `coupon`, `cart`, `chat`, `profile` | varies | 2 each | Good candidates after admin/catalog primitives settle. |

## Repeated Patterns Found

- State views: repeated `CircularProgressIndicator`, empty-state icon/title/message, and retry error views.
- Search bars: repeated `TextField` with search icon, clear button, white fill, rounded border.
- Feedback: repeated `ScaffoldMessenger.showSnackBar` with success/error colors and manual clear.
- Confirm dialogs: repeated delete/cancel dialogs with title, message, confirm color.
- Forms: repeated text fields/dropdowns/switches with validators, section spacing, and submit buttons.
- Images: repeated `Image.network`/`CachedNetworkImage` fallback tiles and delete/thumbnail overlays.
- Constants cleanup: many inline user-facing strings and magic spacing/radius values remain in feature presentation files.

## Core Boundary Notes

`lib/core/di/injection_container.dart` intentionally imports feature modules because it is the composition root.

No feature imports should remain in `core/widgets`, `core/utils`, or `core/network`.

## Batch 1 Completed

- Added common primitives:
  - `core/widgets/state/app_loading_view.dart`
  - `core/widgets/state/app_empty_view.dart`
  - `core/widgets/state/app_error_view.dart`
  - `core/widgets/forms/app_search_field.dart`
  - `core/widgets/dialogs/app_confirm_dialog.dart`
  - `core/utils/ui/app_snack_bar.dart`
- Migrated low-risk admin/catalog patterns:
  - brand state views/search/snackbar
  - category state views/search/snackbar/loading labels
  - coupon state views/search/loading/delete confirmation/snackbar

## Batch 2 Completed

- Migrated admin product page-level common patterns:
  - `admin_product_form_page`: common loading/error view, confirm dialog, snackbar helper, centralized strings.
  - `admin_product_list_page`: common loading/error/empty view, confirm dialog, snackbar helper, centralized strings.
  - `admin_product_detail_page`: common loading/error view.
- Migrated admin product nested presentation feedback:
  - `admin_product_detail_widgets`: snackbar helper and common loading view.
  - `product_form_step2_variants`: snackbar helper, common loading view, shared radius constant.
  - `product_form_step3_images`: snackbar helper for upload/error feedback.
  - `variant_edit_dialog`: centralized labels/validators/actions and removed mojibake inline text.

## Batch 3 Completed

- Cleaned core boundary violations:
  - moved `GlassAppBar` from `core/widgets` to `app/widgets` because it owns app-level actions and imports cart/chat/notification.
  - moved `ProductTactileCard` from `core/widgets` to `features/product/presentation/widgets/shared`.
  - moved `CustomerOrderFilter` from `core/utils` to `features/order/presentation/utils`.
  - decoupled `DioClient` from auth feature model/bloc by using an `onSessionExpired` callback wired in DI.
- Updated product/order/profile imports and the customer order filter test.

## Batch 4 Completed

- Migrated color management common patterns:
  - `color_state_views`: now wraps `AppLoadingView`, `AppEmptyView`, and `AppErrorView`.
  - `color_management_page`: uses `AppConfirmDialog` for delete confirmation and `AppSnackBar` for success/error feedback.
  - `color_product_form_sheet` and `color_printing_form_sheet`: validation feedback now uses `AppSnackBar`.
  - Removed unused `color_delete_dialog.dart` after centralizing delete confirmation.

## Batch 5 Completed

- Completed priority 1 management cleanup for `size`, `brand`, `category`, and `coupon`:
  - `size`: common loading/error/empty/snackbar, confirm dialog, and safe initial load via `Future.microtask`.
  - `brand`: centralized form strings, snackbar helper, bottom-sheet radius constant, and common delete confirmation.
  - `category`: common delete confirmation, snackbar helper, category tree/list constants, and common loading for tree/list mutation states.
  - `coupon`: common snackbar in form flow, centralized coupon list/submit strings, common mutation loading, and cleaned mojibake labels in management list.
- Removed obsolete feature-specific delete dialogs for brand/category.

## Batch 6 Completed

- Migrated priority 2 commerce common patterns for `cart`, `checkout`, `product`, `order`, and `payment`:
  - `cart`: cart page now uses common loading/confirm dialog and centralized cart strings; custom design loading indicator uses `AppLoadingView`.
  - `checkout`: shipping form, order summary, coupon selector/sheet, address picker, payment selector, and cart state wrapper now use centralized strings, `AppSizes`, and common loading/snackbar patterns.
  - `payment`: VNPay cancel confirmation uses `AppConfirmDialog`; payment loading and result screen use common constants and `AppLoadingView`.
  - `order`: detail/list state loading uses `AppLoadingView`; list state dimensions use `AppSizes`.
  - `product`: home/list/detail/catalog/filter/review loading indicators use `AppLoadingView`; product detail feedback uses `AppSnackBar`.
- Verification: `flutter analyze` passes with no issues after the batch.
- Follow-up noted: `cart/presentation/widgets/custom_design_spec_card.dart` still owns a direct use case lookup through `sl<GetCustomDesignSpecUseCase>()`; move that state behind a cubit/bloc or parent-provided view model in a later architecture pass.

## Next Recommended Batches

1. User/support modules: migrate `auth`, `profile`, `address`, `notification`, `chat`, `location`, and `customizer` repeated form, state, snackbar, and dialog primitives.
2. Commerce follow-up: move `CustomDesignSpecCard` use case access out of the widget and continue spacing/string cleanup in deeper order detail/list widgets.
3. Admin order/dashboard and settings/shop cleanup: align remaining loading/snackbar/dialog patterns.
