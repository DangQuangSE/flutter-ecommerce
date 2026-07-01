import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';

class CouponDetailSheet extends StatelessWidget {
  final CouponEntity coupon;

  const CouponDetailSheet({
    super.key,
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    final amountFormat = NumberFormat.decimalPattern('vi_VN');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              coupon.code,
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            _DetailRow(label: 'Loại giảm', value: coupon.discountType.label),
            _DetailRow(label: 'Giá trị giảm', value: _discountText(coupon)),
            _DetailRow(
              label: 'Đơn tối thiểu',
              value: coupon.minOrderAmount == null
                  ? '—'
                  : '${amountFormat.format(coupon.minOrderAmount)}đ',
            ),
            _DetailRow(
              label: 'Giảm tối đa',
              value: coupon.maxDiscountAmount == null
                  ? '—'
                  : '${amountFormat.format(coupon.maxDiscountAmount)}đ',
            ),
            _DetailRow(
              label: 'Hạng yêu cầu',
              value: coupon.requiredTier?.label ?? 'Không yêu cầu',
            ),
            _DetailRow(label: 'Bắt đầu', value: _dateText(coupon.startDate)),
            _DetailRow(label: 'Kết thúc', value: _dateText(coupon.endDate)),
            _DetailRow(
              label: 'Giới hạn dùng',
              value: coupon.usageLimit?.toString() ?? 'Không giới hạn',
            ),
            _DetailRow(label: 'Đã dùng', value: coupon.usedCount.toString()),
            _DetailRow(
              label: 'Trạng thái',
              value: coupon.isActive ? 'Đang hoạt động' : 'Tạm tắt',
            ),
          ],
        ),
      ),
    );
  }

  String _discountText(CouponEntity coupon) {
    if (coupon.discountType == DiscountType.percentage) {
      final value = coupon.discountValue;
      final whole =
          value == value.roundToDouble() ? value.toInt().toString() : '$value';
      return '$whole%';
    }

    return '${NumberFormat.decimalPattern('vi_VN').format(coupon.discountValue)}đ';
  }

  String _dateText(DateTime? date) {
    return date == null ? '—' : DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
