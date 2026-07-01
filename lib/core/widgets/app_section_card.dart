import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';

class AppSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const AppSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: AppSizes.paddingSm,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingMd,
              AppSizes.fontLg,
              AppSizes.paddingMd,
              0,
            ),
            child: Row(
              children: [
                Container(
                  width: AppSizes.fontDisplay,
                  height: AppSizes.fontDisplay,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.paddingSm),
                  ),
                  child: Icon(
                    icon,
                    size: AppSizes.iconSm,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSizes.radiusMd),
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: AppSizes.forgotPasswordFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: AppSizes.radiusLg),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
