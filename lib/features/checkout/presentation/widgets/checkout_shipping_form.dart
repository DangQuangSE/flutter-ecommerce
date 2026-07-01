import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_address_picker.dart';

class CheckoutShippingForm extends StatelessWidget {
  final AddressEntity? selectedAddress;
  final ValueSetter<AddressEntity> onAddressSelected;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const CheckoutShippingForm({
    super.key,
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckoutAddressPicker(
          selectedAddress: selectedAddress,
          onAddressSelected: onAddressSelected,
        ),
        if (selectedAddress != null) ...[
          const SizedBox(height: AppSizes.radiusLg),
          const _ShippingEditHint(),
          const SizedBox(height: AppSizes.paddingMd),
          _CheckoutTextField(
            label: AppStrings.checkoutFullNameLabel,
            controller: nameController,
            validator: (value) => value == null || value.trim().isEmpty
                ? AppStrings.checkoutFullNameRequired
                : null,
          ),
          const SizedBox(height: AppSizes.paddingMd),
          _CheckoutTextField(
            label: AppStrings.checkoutPhoneLabel,
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.checkoutPhoneRequired;
              }
              final phone = value.trim().replaceAll(RegExp(r'\s+'), '');
              if (!RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(phone)) {
                return AppStrings.checkoutPhoneInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.paddingMd),
          _CheckoutTextField(
            label: AppStrings.checkoutShippingAddressLabel,
            controller: addressController,
            maxLines: 2,
            validator: (value) => value == null || value.trim().isEmpty
                ? AppStrings.checkoutShippingAddressRequired
                : null,
          ),
        ],
      ],
    );
  }
}

class _ShippingEditHint extends StatelessWidget {
  const _ShippingEditHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.radiusLg),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(AppSizes.paddingSm),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.edit_outlined,
            size: AppSizes.fontLg,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppSizes.paddingSm),
          Expanded(
            child: Text(
              AppStrings.checkoutShippingEditHint,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _CheckoutTextField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSm - 1,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSizes.radiusSm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF3F3F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.radiusLg,
              vertical: AppSizes.radiusLg,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.paddingSm),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.paddingSm),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorStyle: GoogleFonts.inter(
              fontSize: AppSizes.fontSm,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
