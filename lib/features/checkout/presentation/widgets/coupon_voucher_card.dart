import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';

class CouponVoucherCard extends StatelessWidget {
  final CouponEntity coupon;
  final bool isEligible;
  final bool isSelected;
  final VoidCallback onSelect;
  final String Function(double price) formatPrice;

  const CouponVoucherCard({
    super.key,
    required this.coupon,
    required this.isEligible,
    required this.isSelected,
    required this.onSelect,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: isEligible ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFC1C6D7).withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isEligible
              ? theme.colorScheme.surface
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            _VoucherIcon(isEligible: isEligible),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _VoucherText(
                  coupon: coupon,
                  isEligible: isEligible,
                  formatPrice: formatPrice,
                ),
              ),
            ),
            _VoucherAction(
              isEligible: isEligible,
              isSelected: isSelected,
              onSelect: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherIcon extends StatelessWidget {
  final bool isEligible;

  const _VoucherIcon({required this.isEligible});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 90,
      decoration: BoxDecoration(
        color: isEligible ? AppColors.primary : Colors.grey[400],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(9),
          bottomLeft: Radius.circular(9),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.confirmation_num_outlined,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class _VoucherText extends StatelessWidget {
  final CouponEntity coupon;
  final bool isEligible;
  final String Function(double price) formatPrice;

  const _VoucherText({
    required this.coupon,
    required this.isEligible,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = _description();
    final minOrderText = coupon.minOrderAmount == null
        ? ''
        : 'Đơn tối thiểu ${formatPrice(coupon.minOrderAmount!)}';
    final expiryText = coupon.endDate == null
        ? ''
        : 'Hạn dùng: ${coupon.endDate!.day}/${coupon.endDate!.month}/${coupon.endDate!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          coupon.code,
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isEligible
                ? AppColors.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (minOrderText.isNotEmpty) ...[
          SizedBox(height: 2),
          Text(
            minOrderText,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (expiryText.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            expiryText,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textHint,
            ),
          ),
        ],
      ],
    );
  }

  String _description() {
    if (coupon.discountType == DiscountType.percentage) {
      var desc = 'Giảm ${coupon.discountValue.toStringAsFixed(0)}%';
      if (coupon.maxDiscountAmount != null) {
        desc += ' (Tối đa ${formatPrice(coupon.maxDiscountAmount!)})';
      }
      return desc;
    }
    return 'Giảm ${formatPrice(coupon.discountValue)}';
  }
}

class _VoucherAction extends StatelessWidget {
  final bool isEligible;
  final bool isSelected;
  final VoidCallback onSelect;

  const _VoucherAction({
    required this.isEligible,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEligible) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(
          Icons.info_outline_rounded,
          color: Colors.grey[400],
          size: 20,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(
          isSelected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          color: AppColors.primary,
        ),
        onPressed: onSelect,
      ),
    );
  }
}
