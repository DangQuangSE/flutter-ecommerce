import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

/// The "Chỉ đường" pill overlaid on the store map. Shows a spinner and is
/// disabled while a route is being computed (R11 — guards double-taps).
class ShopMapDirectionsFab extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const ShopMapDirectionsFab({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
        disabledForegroundColor: AppColors.textOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        ),
        elevation: 4,
      ),
      icon: loading
          ? const SizedBox(
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textOnPrimary,
                ),
              ),
            )
          : const Icon(Icons.directions_rounded, size: AppSizes.iconMd),
      label: Text(
        loading
            ? AppStrings.shopDirectionsLoading
            : AppStrings.shopGetDirections,
        style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
      ),
    );
  }
}
