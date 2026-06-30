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

## Existing Core Boundary Issues To Handle Later

These existed before the first common batch and should be separated in a dedicated boundary pass:

- `lib/core/widgets/glass_app_bar.dart` imports notification/chat/cart feature classes.
- `lib/core/widgets/product_tactile_card.dart` imports product feature entities.
- `lib/core/network/dio_client.dart` imports auth feature bloc/model.
- `lib/core/utils/customer_order_filter.dart` imports order feature entity.

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

## Next Recommended Batches

1. Core boundary pass: move feature-specific core widgets/utilities out of `core` or invert dependencies.
2. Management modules: migrate `color`, `size`, `brand`, `category`, `coupon` forms/dialogs to common form/dialog helpers.
3. Commerce modules: migrate cart/checkout/product repeated state, image, and card primitives.
4. User/support modules: migrate auth/profile/address/notification/chat repeated form, state, snackbar, and dialog primitives.
