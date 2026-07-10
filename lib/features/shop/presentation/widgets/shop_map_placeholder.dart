import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

/// Shown in place of the map when the shop has no coordinate and its address
/// could not be geocoded — keeps the screen usable (address card still below).
class ShopMapPlaceholder extends StatelessWidget {
  final double height;

  const ShopMapPlaceholder({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: AppColors.canvasLight,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_off_rounded,
            size: AppSizes.iconXl,
            color: AppColors.borderGray,
          ),
          const SizedBox(height: AppSizes.paddingSm),
          Text(
            AppStrings.shopMapUnavailable,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMd,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
