import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class CouponSubmitButton extends StatelessWidget {
  final bool isEditing;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const CouponSubmitButton({
    super.key,
    required this.isEditing,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
        child: isSubmitting
            ? const SizedBox.square(
                dimension: AppSizes.iconMd + 2,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isEditing
                    ? AppStrings.adminCouponSaveSubmit
                    : AppStrings.adminCouponCreateSubmit,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
