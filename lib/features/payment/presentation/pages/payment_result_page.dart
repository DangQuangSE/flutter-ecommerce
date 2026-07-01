import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class PaymentResultPage extends StatelessWidget {
  final bool success;
  final String message;

  const PaymentResultPage({
    super.key,
    required this.success,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                size: AppSizes.iconXl + AppSizes.paddingSm,
                color: success ? AppColors.success : AppColors.error,
              ),
              const SizedBox(height: AppSizes.paddingXl),
              Text(
                success
                    ? AppStrings.paymentSuccessTitle
                    : AppStrings.paymentFailureTitle,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.fontHeading,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.radiusLg),
              Text(
                message,
                style: GoogleFonts.inter(fontSize: AppSizes.fontLg),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.fontDisplay),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.goNamed(AppRoutes.home),
                  child: const Text(AppStrings.paymentBackHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
