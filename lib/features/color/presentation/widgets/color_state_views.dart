import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';

class ColorLoadingView extends StatelessWidget {
  const ColorLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

class ColorEmptyView extends StatelessWidget {
  final String message;

  const ColorEmptyView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.palette_outlined,
              size: AppSizes.iconXl, color: AppColors.divider),
          AppSizes.spacingMd,
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ColorErrorView extends StatelessWidget {
  final String message;

  const ColorErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.inter(color: AppColors.error),
      ),
    );
  }
}
