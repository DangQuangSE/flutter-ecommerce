import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class PricingFooter extends StatelessWidget {
  final double totalPrice;
  final double totalPrintingPrice;
  final VoidCallback onReset;
  final VoidCallback onConfirm;

  const PricingFooter({
    super.key,
    required this.totalPrice,
    required this.totalPrintingPrice,
    required this.onReset,
    required this.onConfirm,
  });

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.fontLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: AppSizes.radiusMd,
            offset: Offset(0, -3),
          )
        ],
        border: Border(
          top: BorderSide(color: AppColors.borderGray.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _PriceSummary(
              totalPrice: _formatPrice(totalPrice),
              totalPrintingPrice: _formatPrice(totalPrintingPrice),
            ),
          ),
          SizedBox(width: AppSizes.paddingMd - 4),
          Expanded(
            flex: 2,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.fontLg),
                side: const BorderSide(color: AppColors.borderGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              onPressed: onReset,
              child: Text(
                AppStrings.productFilterReset,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.paddingSm + 2),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.fontLg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              onPressed: onConfirm,
              child: Text(
                AppStrings.productFilterApply,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final String totalPrice;
  final String totalPrintingPrice;

  const _PriceSummary({
    required this.totalPrice,
    required this.totalPrintingPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.customizerTotalProduct,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 2),
        Text(
          '$totalPrice ₫',
          style: GoogleFonts.lexend(
            fontSize: AppSizes.paddingLg,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Text(
              AppStrings.customizerPrintingPrice(totalPrintingPrice),
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontXs + 1,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            AppSizes.spacingXs,
            Expanded(
              child: Text(
                AppStrings.customizerPrintingPriceHint,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
