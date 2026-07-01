import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class ProductDetailErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ProductDetailErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              SizedBox(height: 16),
              Text(
                AppStrings.productDetailLoadError,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
