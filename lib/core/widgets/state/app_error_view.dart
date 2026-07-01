import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class AppErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const AppErrorView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: AppSizes.iconXl - AppSizes.paddingMd,
                color: AppColors.error,
              ),
              SizedBox(height: AppSizes.paddingMd),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.submitButtonFontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSizes.paddingSm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textSecondary,
                ),
              ),
              if (onRetry != null) ...[
                SizedBox(height: AppSizes.paddingLg),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppStrings.retry),
                ),
              ],
            ],
          ),
        ),
      );
}
