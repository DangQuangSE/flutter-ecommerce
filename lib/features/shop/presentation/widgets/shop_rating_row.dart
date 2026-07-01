import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

/// Displays a star icon, the numeric rating, and the rating count.
class ShopRatingRow extends StatelessWidget {
  final double? rating;
  final int ratingCount;

  const ShopRatingRow({
    super.key,
    required this.rating,
    required this.ratingCount,
  });

  @override
  Widget build(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(Icons.star_rounded, color: AppColors.warning, size: AppSizes.iconMd),
        SizedBox(width: AppSizes.paddingXs),
        Text(
          rating!.toStringAsFixed(1),
          style: TextStyle(
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: AppSizes.paddingXs),
        Text(
          AppStrings.shopRatingCount(ratingCount),
          style: TextStyle(
            fontSize: AppSizes.fontLg,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
