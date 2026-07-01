import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/utils/price_formatter.dart';

class CartOrderSummary extends StatelessWidget {
  final int selectedTotalItems;
  final double selectedTotalPrice;

  const CartOrderSummary({
    super.key,
    required this.selectedTotalItems,
    required this.selectedTotalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạm tính ($selectedTotalItems sản phẩm)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                formatPrice(selectedTotalPrice),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao hàng hỏa tốc',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Miễn phí',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF009933),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TỔNG CỘNG',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              Transform(
                transform: Matrix4.skewX(-0.12),
                child: Text(
                  formatPrice(selectedTotalPrice),
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
