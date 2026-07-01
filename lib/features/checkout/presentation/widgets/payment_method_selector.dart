import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/payment_method_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodSelector extends StatelessWidget {
  final CheckoutPaymentOption selected;
  final ValueChanged<CheckoutPaymentOption> onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.radiusLg),
      decoration: BoxDecoration(
        color: Colors.white,
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
          _PaymentOptionTile(
            option: CheckoutPaymentOption.cod,
            icon: Icons.local_shipping_outlined,
            selected: selected == CheckoutPaymentOption.cod,
            onTap: () => onChanged(CheckoutPaymentOption.cod),
          ),
          const SizedBox(height: AppSizes.paddingSm),
          _PaymentOptionTile(
            option: CheckoutPaymentOption.vnpay,
            icon: Icons.account_balance_wallet_outlined,
            selected: selected == CheckoutPaymentOption.vnpay,
            onTap: () => onChanged(CheckoutPaymentOption.vnpay),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final CheckoutPaymentOption option;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.option,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.paddingSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.radiusLg,
            vertical: AppSizes.radiusLg,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.04)
                : const Color(0xFFF3F3F8),
            borderRadius: BorderRadius.circular(AppSizes.paddingSm),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : const Color(0xFFC1C6D7).withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppSizes.paddingXl,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.radiusLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.forgotPasswordFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: AppSizes.fontHeading,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
