import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginOrDivider extends StatelessWidget {
  const LoginOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.divider.withValues(alpha: 0.95),
            thickness: 1.2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.loginOrDivider,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.9),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.divider.withValues(alpha: 0.95),
            thickness: 1.2,
          ),
        ),
      ],
    );
  }
}
