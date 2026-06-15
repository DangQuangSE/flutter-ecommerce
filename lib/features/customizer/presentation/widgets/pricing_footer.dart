import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';

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
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))
        ],
        border: Border(
            top:
                BorderSide(color: AppColors.borderGray.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TỔNG CỘNG SẢN PHẨM',
                  style: GoogleFonts.inter(
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatPrice(totalPrice)} ₫',
                  style: GoogleFonts.lexend(
                      fontSize: AppSizes.paddingLg,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Giá in thêm: ${_formatPrice(totalPrintingPrice)} ₫',
                      style: GoogleFonts.inter(
                          fontSize: AppSizes.fontXs + 1,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    AppSizes.spacingXs,
                    Expanded(
                      child: Text(
                        '(Gồm phôi & lớp in)',
                        style: GoogleFonts.inter(
                            fontSize: AppSizes.fontXs,
                            color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.paddingMd - 4),
          Expanded(
            flex: 2,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.borderGray),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
              ),
              onPressed: onReset,
              child: Text('Đặt lại',
                  style: GoogleFonts.inter(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ),
          ),
          const SizedBox(width: AppSizes.paddingSm + 2),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
              ),
              onPressed: onConfirm,
              child: Text('Xác nhận',
                  style: GoogleFonts.lexend(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
