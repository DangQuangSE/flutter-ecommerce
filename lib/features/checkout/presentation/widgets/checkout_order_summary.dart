import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final List<CartItemEntity> checkoutItems;
  final double discount;
  final String Function(double price) formatPrice;

  const CheckoutOrderSummary({
    super.key,
    required this.checkoutItems,
    required this.discount,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalItems = checkoutItems.fold(0, (sum, e) => sum + e.quantity);
    final subtotal = checkoutItems.fold(
      0.0,
      (sum, e) => sum + (e.price + e.printingPrice) * e.quantity,
    );
    final finalPrice = subtotal - discount;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label:
                '${AppStrings.checkoutSubtotalLabel} ($totalItems ${AppStrings.checkoutProductCountSuffix})',
            value: formatPrice(subtotal),
          ),
          if (discount > 0) ...[
            SizedBox(height: AppSizes.radiusMd),
            _SummaryRow(
              label: AppStrings.checkoutVoucherDiscountLabel,
              value: '-${formatPrice(discount)}',
              color: AppColors.error,
            ),
          ],
          SizedBox(height: AppSizes.radiusMd),
          const _SummaryRow(
            label: AppStrings.checkoutExpressShippingLabel,
            value: AppStrings.checkoutFreeShipping,
            valueColor: Color(0xFF009933),
          ),
          SizedBox(height: AppSizes.radiusLg),
          Container(
            height: 1,
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
          ),
          SizedBox(height: AppSizes.radiusLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppStrings.checkoutGrandTotalLabel,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.forgotPasswordFontSize,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              Transform(
                transform: Matrix4.skewX(-0.12),
                child: Text(
                  formatPrice(finalPrice),
                  style: GoogleFonts.lexend(
                    fontSize: AppSizes.fontHeading,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = color ?? theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w700,
            color: valueColor ?? color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
