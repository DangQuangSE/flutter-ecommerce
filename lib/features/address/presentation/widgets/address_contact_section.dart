import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/app_section_card.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_form_helpers.dart';

String? _validatePhone(String? v) {
  if (v == null || v.trim().isEmpty) return AppStrings.addressPhoneRequired;
  if (!RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$').hasMatch(v.trim())) {
    return AppStrings.addressPhoneInvalid;
  }
  return null;
}

class AddressContactSection extends StatelessWidget {
  final TextEditingController fullNameCtrl;
  final TextEditingController phoneCtrl;

  const AddressContactSection({
    super.key,
    required this.fullNameCtrl,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: AppStrings.addressContactSectionTitle,
      icon: Icons.person_outline_rounded,
      children: [
        AddressFieldLabel(
          label: AppStrings.addressFullNameLabel,
          child: AddressTextField(
            controller: fullNameCtrl,
            hint: AppStrings.addressFullNameHint,
            icon: Icons.person_outline,
            validator: (v) => v == null || v.trim().isEmpty
                ? AppStrings.addressFullNameRequired
                : null,
          ),
        ),
        const SizedBox(height: AppSizes.fontLg),
        AddressFieldLabel(
          label: AppStrings.addressPhoneLabel,
          child: AddressTextField(
            controller: phoneCtrl,
            hint: AppStrings.addressPhoneHint,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
        ),
      ],
    );
  }

}
