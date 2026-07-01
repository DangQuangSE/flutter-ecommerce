import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class AuthTabBar extends StatelessWidget {
  final int activeIndex;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const AuthTabBar({
    super.key,
    required this.activeIndex,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onLoginTap,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusXl),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.tabVerticalPadding,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: activeIndex == 0
                        ? AppColors.primary
                        : AppColors.textSecondaryLight,
                    width: AppSizes.borderThick,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  AppStrings.loginTitle,
                  style: GoogleFonts.inter(
                    fontWeight:
                        activeIndex == 0 ? FontWeight.w700 : FontWeight.w500,
                    fontSize: AppSizes.fontLg,
                    color: activeIndex == 0
                        ? AppColors.primary
                        : AppColors.textSecondaryLight,
                    letterSpacing: AppSizes.letterSpacingWide / 2,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onRegisterTap,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(AppSizes.radiusXl),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.tabVerticalPadding,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: activeIndex == 1
                        ? AppColors.primary
                        : AppColors.textSecondaryLight,
                    width: AppSizes.borderThick,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  AppStrings.registerTitle,
                  style: GoogleFonts.inter(
                    fontWeight:
                        activeIndex == 1 ? FontWeight.w700 : FontWeight.w500,
                    fontSize: AppSizes.fontLg,
                    color: activeIndex == 1
                        ? AppColors.primary
                        : AppColors.textSecondaryLight,
                    letterSpacing: AppSizes.letterSpacingWide / 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
