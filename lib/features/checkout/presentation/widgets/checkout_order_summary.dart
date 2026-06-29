import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
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
    final totalItems = checkoutItems.fold(0, (sum, e) => sum + e.quantity);
    final subtotal = checkoutItems.fold(
      0.0,
      (sum, e) => sum + (e.price + e.printingPrice) * e.quantity,
    );
    final finalPrice = subtotal - discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            label: 'Táº¡m tÃ­nh ($totalItems sáº£n pháº©m)',
            value: formatPrice(subtotal),
          ),
          if (discount > 0) ...[
            const SizedBox(height: 10),
            _SummaryRow(
              label: 'Giáº£m giÃ¡ (Voucher)',
              value: '-${formatPrice(discount)}',
              color: AppColors.error,
            ),
          ],
          const SizedBox(height: 10),
          const _SummaryRow(
            label: 'Giao hÃ ng há»a tá»‘c',
            value: 'Miá»…n phÃ­',
            valueColor: Color(0xFF009933),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tá»”NG Cá»˜NG',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              Transform(
                transform: Matrix4.skewX(-0.12),
                child: Text(
                  formatPrice(finalPrice),
                  style: GoogleFonts.lexend(
                    fontSize: 22,
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
    final textColor = color ?? AppColors.textSecondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
