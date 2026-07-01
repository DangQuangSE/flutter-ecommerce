import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';

class ProductImagesHeader extends StatelessWidget {
  final int count;
  final int maxImages;

  const ProductImagesHeader({
    super.key,
    required this.count,
    required this.maxImages,
  });

  @override
  Widget build(BuildContext context) => Text(
        AppStrings.adminProductImagesTitle(count, maxImages),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      );
}

class ProductAddImageTile extends StatelessWidget {
  final VoidCallback onTap;

  const ProductAddImageTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: AppSizes.adminProductImageTileSize,
          height: AppSizes.adminProductImageTileSize,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
            color: AppColors.primary.withValues(alpha: 0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_rounded,
                color: AppColors.primary,
                size: AppSizes.iconLg,
              ),
              SizedBox(height: AppSizes.paddingXs),
              Text(
                AppStrings.adminProductImagesAdd,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
}

class ProductImageTile extends StatelessWidget {
  final ProductImageEntity image;
  final bool isUploading;
  final VoidCallback onDelete;

  const ProductImageTile({
    super.key,
    required this.image,
    required this.isUploading,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: AppSizes.adminProductImageTileSize,
        height: AppSizes.adminProductImageTileSize,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
              child: CachedNetworkImage(
                imageUrl: image.imageUrl,
                width: AppSizes.adminProductImageTileSize,
                height: AppSizes.adminProductImageTileSize,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const _ImageErrorPlaceholder(),
              ),
            ),
            if (image.isThumbnail) const _ThumbnailBadge(),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: isUploading ? null : onDelete,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingXs / 2),
                  decoration: BoxDecoration(
                    color: isUploading ? AppColors.textHint : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: AppSizes.fontLg,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class ProductImageBasicInfoWarning extends StatelessWidget {
  const ProductImageBasicInfoWarning({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSizes.paddingMd),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingSm + 4),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
            border: Border.all(color: AppColors.warning),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: AppSizes.iconSm,
              ),
              SizedBox(width: AppSizes.paddingSm),
              Expanded(
                child: Text(
                  AppStrings.adminProductImagesBasicInfoRequired,
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: AppSizes.forgotPasswordFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class ProductImageStepNavigation extends StatelessWidget {
  final bool isUploading;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const ProductImageStepNavigation({
    super.key,
    required this.isUploading,
    required this.isSubmitting,
    required this.onBack,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMd,
          AppSizes.paddingSm,
          AppSizes.paddingMd,
          AppSizes.paddingMd,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isUploading ? null : onBack,
                icon: Icon(Icons.arrow_back_rounded),
                label: Text(AppStrings.adminProductImagesBack),
              ),
            ),
            SizedBox(width: AppSizes.paddingMd),
            Expanded(
              child: ElevatedButton(
                onPressed: (isSubmitting || isUploading) ? null : onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingSm + 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
                  ),
                ),
                child: isSubmitting
                    ? SizedBox(
                        height: AppSizes.iconMd,
                        width: AppSizes.iconMd,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppStrings.adminProductImagesComplete,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      );
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        width: AppSizes.adminProductImageTileSize,
        height: AppSizes.adminProductImageTileSize,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
        ),
        child: Icon(Icons.broken_image, color: AppColors.textHint),
      );
}

class _ThumbnailBadge extends StatelessWidget {
  const _ThumbnailBadge();

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: AppSizes.paddingXs,
        left: AppSizes.paddingXs,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingXs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.paddingXs),
          ),
          child: Text(
            AppStrings.adminProductImagesThumbnail,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontXs,
            ),
          ),
        ),
      );
}
