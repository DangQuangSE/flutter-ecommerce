import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';

class ProductListErrorView extends StatelessWidget {
  final String message;

  const ProductListErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSizes.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: AppSizes.buttonMinHeight,
              color: AppColors.error,
            ),
            AppSizes.spacingMd,
            Text(
              AppStrings.productListLoadError,
              style: GoogleFonts.lexend(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            AppSizes.spacingSm,
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
              ),
            ),
            AppSizes.spacingLg,
            ElevatedButton(
              onPressed: () {
                context.read<ProductBloc>().add(const ProductListRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.paddingSm),
                ),
              ),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
