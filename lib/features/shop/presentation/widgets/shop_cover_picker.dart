import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

/// Full-width tappable cover image for the admin shop config form.
/// Sized by the parent — does not impose its own height.
class ShopCoverPicker extends StatelessWidget {
  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onTap;

  const ShopCoverPicker({
    super.key,
    this.imageUrl,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.shopCoverPickerLabel,
      button: true,
      child: GestureDetector(
        onTap: isUploading ? null : onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CoverBackground(imageUrl: imageUrl),
            Positioned(
              right: AppSizes.paddingMd,
              bottom: AppSizes.paddingMd,
              child: _CameraIcon(isUploading: isUploading),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverBackground extends StatelessWidget {
  final String? imageUrl;

  const _CoverBackground({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const _CoverPlaceholder(),
      );
    }
    return const _CoverPlaceholder();
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(
          Icons.store_mall_directory_rounded,
          size: AppSizes.iconXl,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _CameraIcon extends StatelessWidget {
  final bool isUploading;

  const _CameraIcon({required this.isUploading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: isUploading
          ? const SizedBox(
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: AppSizes.iconSm,
            ),
    );
  }
}
