# Fix Product Detail Header Issue

## Goal
Fix the header on the product detail page where the AppBar is solid blue, making the title and action icons (which are also blue) invisible. 

## Scope Challenge
- **Exists?** Yes, fixing the existing `ProductDetailAppBar`.
- **Minimum?** Update the AppBar's `backgroundColor` and optionally `extendBodyBehindAppBar` to ensure it renders correctly and looks modern.
- **Complexity?** Fast — only a couple of UI widget files need small adjustments.
- **Mode:** Fast
- **Test:** default

## Proposed Changes

### Phase 1: Update AppBar Background
- **Target:** `lib/features/product/presentation/widgets/detail/product_detail_app_bar.dart`
- **Change:** Change `backgroundColor` to `theme.colorScheme.surface` or `Colors.transparent`. In the current implementation, it uses `theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface`, and since `appBarTheme.backgroundColor` is `AppColors.primary`, the AppBar becomes blue. We will force it to `theme.colorScheme.surface` so it has a white/dark surface background, making the blue title and icons visible.

### Phase 2 (Optional but recommended): Transparent Header Overlay
- **Target:** `lib/features/product/presentation/widgets/detail/product_detail_content.dart`
- **Change:** Set `extendBodyBehindAppBar: true` in the `Scaffold` and use `backgroundColor: Colors.transparent` in `ProductDetailAppBar` to let the product image go all the way up, creating a more modern e-commerce look. We would then need to wrap the icon buttons in slightly opaque circles so they are visible over the image. 

*I will ask the user which approach they prefer in the verification step.*
