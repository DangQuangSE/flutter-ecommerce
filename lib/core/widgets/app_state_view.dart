import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';

class AppStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color actionColor;

  const AppStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor = AppColors.textSecondary,
    this.iconBackgroundColor = AppColors.canvasLight,
    this.actionColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StateIcon(
              icon: icon,
              color: iconColor,
              backgroundColor: iconBackgroundColor,
            ),
            const SizedBox(height: AppSizes.paddingXl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: AppSizes.fontHeading,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.radiusLg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontLg,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSizes.fontDisplay),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: GoogleFonts.lexend(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _StateIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.borderGray.withValues(alpha: 0.3),
        ),
      ),
      child: Icon(
        icon,
        size: AppSizes.iconXl,
        color: color,
      ),
    );
  }
}
