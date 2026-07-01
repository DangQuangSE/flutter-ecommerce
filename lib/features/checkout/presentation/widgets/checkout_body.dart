import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/constants/payment_method_constants.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_coupon_selector.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_order_summary.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_section_header.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_shipping_form.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_sticky_footer.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/payment_method_selector.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';

class CheckoutBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<CartItemEntity> checkoutItems;
  final AddressEntity? selectedAddress;
  final CouponEntity? selectedCoupon;
  final CheckoutPaymentOption selectedPayment;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final ValueChanged<AddressEntity> onAddressSelected;
  final ValueChanged<CheckoutPaymentOption> onPaymentChanged;
  final double Function(double subtotal) calculateDiscount;
  final String Function(double price) formatPrice;
  final void Function(
    BuildContext context,
    double subtotal, {
    required List<CouponEntity> coupons,
    required String? errorMessage,
  }) onOpenCoupon;
  final VoidCallback onConfirm;

  const CheckoutBody({
    super.key,
    required this.formKey,
    required this.checkoutItems,
    required this.selectedAddress,
    required this.selectedCoupon,
    required this.selectedPayment,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.onAddressSelected,
    required this.onPaymentChanged,
    required this.calculateDiscount,
    required this.formatPrice,
    required this.onOpenCoupon,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final checkoutTotalPrice = checkoutItems.fold(
      0.0,
      (sum, e) => sum + (e.price + e.printingPrice) * e.quantity,
    );
    final discount = calculateDiscount(checkoutTotalPrice);

    return Form(
      key: formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CheckoutSectionHeader(
                    title: AppStrings.checkoutShippingSectionTitle,
                    icon: Icons.local_shipping_outlined,
                  ),
                  const SizedBox(height: AppSizes.radiusLg),
                  CheckoutShippingForm(
                    selectedAddress: selectedAddress,
                    onAddressSelected: onAddressSelected,
                    nameController: nameController,
                    phoneController: phoneController,
                    addressController: addressController,
                  ),
                  const SizedBox(height: AppSizes.iconLg),
                  const CheckoutSectionHeader(
                    title: AppStrings.checkoutPaymentSectionTitle,
                    icon: Icons.payments_outlined,
                  ),
                  const SizedBox(height: AppSizes.radiusLg),
                  PaymentMethodSelector(
                    selected: selectedPayment,
                    onChanged: onPaymentChanged,
                  ),
                  const SizedBox(height: AppSizes.iconLg),
                  const CheckoutSectionHeader(
                    title: AppStrings.checkoutCouponSectionTitle,
                    icon: Icons.local_offer_outlined,
                  ),
                  const SizedBox(height: AppSizes.radiusLg),
                  CheckoutCouponSelector(
                    selectedCoupon: selectedCoupon,
                    discount: discount,
                    subtotal: checkoutTotalPrice,
                    formatPrice: formatPrice,
                    onOpen: onOpenCoupon,
                  ),
                  const SizedBox(height: AppSizes.iconLg),
                  CheckoutOrderSummary(
                    checkoutItems: checkoutItems,
                    discount: discount,
                    formatPrice: formatPrice,
                  ),
                  const SizedBox(height: AppSizes.fontDisplay),
                ],
              ),
            ),
          ),
          CheckoutStickyFooter(onConfirm: onConfirm),
        ],
      ),
    );
  }
}
