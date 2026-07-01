import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
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
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMd,
              vertical: AppSizes.fontLg,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
                  size: AppSizes.iconMd,
                ),
                SizedBox(width: AppSizes.radiusLg),
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
                  const AppLoadingView(size: AppSizes.fontLg)
                else if (hasError)
                  Icon(
                    Icons.refresh_rounded,
                    color: AppColors.error,
                    size: AppSizes.fontXxl,
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textHint.withValues(alpha: 0.7),
                    size: AppSizes.fontLg,
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
              ? AppStrings.checkoutCouponApplied(selectedCoupon!.code)
              : AppStrings.checkoutVoucherTitle,
          style: GoogleFonts.inter(
            fontSize: AppSizes.forgotPasswordFontSize,
            fontWeight: FontWeight.w700,
            color: hasCoupon ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          _subtitle(hasCoupon),
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSm,
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
    if (hasCoupon) return AppStrings.checkoutCouponSaved(formatPrice(discount));
    if (hasError) return AppStrings.checkoutCouponLoadError;
    if (isLoading) return AppStrings.checkoutCouponLoading;
    return AppStrings.checkoutCouponChooseOrEnter;
  }
}
