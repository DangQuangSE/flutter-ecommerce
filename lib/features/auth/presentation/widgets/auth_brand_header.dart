import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class AuthBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthBrandHeader({
    super.key,
    this.title = AppStrings.brandName,
    this.subtitle = AppStrings.authTagline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform(
          transform: Matrix4.skewX(-0.12),
          alignment: Alignment.center,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                AppColors.primary,
                Color(0xFF0058BC), // Premium deeper blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.brandHeadingSize,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.white, // Required for ShaderMask to work correctly
                  letterSpacing: -1.5,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          subtitle.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.textSecondaryLight.withValues(alpha: 0.95),
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }
}

