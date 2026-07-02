import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/app_section_card.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_form_helpers.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressOptionsSection extends StatelessWidget {
  final TextEditingController labelCtrl;
  final bool isDefault;
  final VoidCallback onToggleDefault;

  const AddressOptionsSection({
    super.key,
    required this.labelCtrl,
    required this.isDefault,
    required this.onToggleDefault,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: AppStrings.addressOptionsSectionTitle,
      icon: Icons.tune_outlined,
      children: [
        AddressFieldLabel(
          label: AppStrings.addressLabelLabel,
          isRequired: false,
          optionalHint: AppStrings.addressOptionalLabelExample,
          child: AddressTextField(
            controller: labelCtrl,
            hint: AppStrings.addressLabelHint,
            icon: Icons.label_outline,
          ),
        ),
        SizedBox(height: AppSizes.paddingSm),
        _DefaultToggle(isDefault: isDefault, onToggle: onToggleDefault),
      ],
    );
  }
}

class _DefaultToggle extends StatelessWidget {
  final bool isDefault;
  final VoidCallback onToggle;

  const _DefaultToggle({required this.isDefault, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDefault
              ? AppColors.primary.withValues(alpha: 0.06)
              : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDefault ? AppColors.primary : const Color(0xFFE5E7EB),
            width: isDefault ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 18,
              color: isDefault ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.addressIsDefaultHint,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDefault ? AppColors.primary : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    AppStrings.addressDefaultOrderHint,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDefault ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDefault ? AppColors.primary : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: isDefault
                  ? Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
