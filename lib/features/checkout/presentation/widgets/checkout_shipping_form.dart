import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
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
          const SizedBox(height: 12),
          const _ShippingEditHint(),
          const SizedBox(height: 16),
          _CheckoutTextField(
            label: 'Há»Œ VÃ€ TÃŠN',
            controller: nameController,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lÃ²ng nháº­p há» vÃ  tÃªn'
                : null,
          ),
          const SizedBox(height: 16),
          _CheckoutTextField(
            label: 'Sá» ÄIá»†N THOáº I',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lÃ²ng nháº­p sá»‘ Ä‘iá»‡n thoáº¡i';
              }
              final phone = value.trim().replaceAll(RegExp(r'\s+'), '');
              if (!RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(phone)) {
                return 'Sá»‘ Ä‘iá»‡n thoáº¡i khÃ´ng há»£p lá»‡ (VD: 0912345678)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _CheckoutTextField(
            label: 'Äá»ŠA CHá»ˆ GIAO HÃ€NG',
            controller: addressController,
            maxLines: 2,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lÃ²ng nháº­p Ä‘á»‹a chá»‰ giao hÃ ng'
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.edit_outlined,
            size: 14,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Báº¡n cÃ³ thá»ƒ chá»‰nh sá»­a thÃ´ng tin giao hÃ ng bÃªn dÆ°á»›i náº¿u cáº§n.',
              style: GoogleFonts.inter(
                fontSize: 11,
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.error),
          ),
        ),
      ],
    );
  }
}
