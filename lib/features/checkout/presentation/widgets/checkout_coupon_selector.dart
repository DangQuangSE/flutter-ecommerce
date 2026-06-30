import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_state.dart';

class CheckoutCouponSelector extends StatelessWidget {
  final CouponEntity? selectedCoupon;
  final double discount;
  final double subtotal;
  final String Function(double price) formatPrice;
  final void Function(
    BuildContext context,
    double subtotal, {
    required List<CouponEntity> coupons,
    required String? errorMessage,
  }) onOpen;

  const CheckoutCouponSelector({
    super.key,
    required this.selectedCoupon,
    required this.discount,
    required this.subtotal,
    required this.formatPrice,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoupon = selectedCoupon != null;

    return BlocBuilder<CouponCubit, CouponState>(
      builder: (context, couponState) {
        final isLoading =
            couponState is CouponLoading || couponState is CouponInitial;
        final hasError = couponState is CouponError;
        final coupons = couponState is CouponLoaded
            ? couponState.coupons
            : const <CouponEntity>[];
        final errorMessage =
            couponState is CouponError ? couponState.message : null;

        return InkWell(
          onTap: isLoading
              ? null
              : hasError
                  ? () => context.read<CouponCubit>().loadUserAvailableCoupons()
                  : () => onOpen(
                        context,
                        subtotal,
                        coupons: coupons,
                        errorMessage: errorMessage,
                      ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasCoupon
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : const Color(0xFFC1C6D7).withValues(alpha: 0.3),
                width: hasCoupon ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_num_outlined,
                  color:
                      hasCoupon ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CouponText(
                    selectedCoupon: selectedCoupon,
                    discount: discount,
                    isLoading: isLoading,
                    hasError: hasError,
                    formatPrice: formatPrice,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (hasError)
                  const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.error,
                    size: 18,
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textHint.withValues(alpha: 0.7),
                    size: 14,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CouponText extends StatelessWidget {
  final CouponEntity? selectedCoupon;
  final double discount;
  final bool isLoading;
  final bool hasError;
  final String Function(double price) formatPrice;

  const _CouponText({
    required this.selectedCoupon,
    required this.discount,
    required this.isLoading,
    required this.hasError,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoupon = selectedCoupon != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasCoupon
              ? 'Đã áp dụng mã: ${selectedCoupon!.code}'
              : 'Sport Pro Voucher',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: hasCoupon ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _subtitle(hasCoupon),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: hasCoupon
                ? const Color(0xFF009933)
                : hasError
                    ? AppColors.error
                    : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  String _subtitle(bool hasCoupon) {
    if (hasCoupon) return 'Tiết kiệm được ${formatPrice(discount)}';
    if (hasError) return 'Không tải được mã giảm giá. Nhấn để thử lại.';
    if (isLoading) return 'Đang tải mã giảm giá...';
    return 'Chọn hoặc nhập mã giảm giá';
  }
}
