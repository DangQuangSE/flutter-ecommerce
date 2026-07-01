import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';

class MaterialCard extends StatelessWidget {
  final String title;
  final String priceAdd;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;

  const MaterialCard({
    super.key,
    required this.title,
    required this.priceAdd,
    required this.desc,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSizes.cardPadding,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.02)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderGray.withValues(alpha: 0.5),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  width: isSelected ? 5.0 : 1.5,
                ),
              ),
            ),
            AppSizes.spacingSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: GoogleFonts.inter(
                              fontSize: AppSizes.fontLg - 1,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface)),
                      Text(priceAdd,
                          style: GoogleFonts.lexend(
                              fontSize: AppSizes.fontMd,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary)),
                    ],
                  ),
                  AppSizes.spacingXs,
                  Text(desc,
                      style: GoogleFonts.inter(
                          fontSize: AppSizes.fontSm,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
