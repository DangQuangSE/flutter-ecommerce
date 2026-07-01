import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class SizeGroupNameField extends StatelessWidget {
  final TextEditingController controller;

  const SizeGroupNameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: AppStrings.adminSizeGroupNameLabel,
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          (value == null || value.trim().isEmpty)
              ? AppStrings.adminSizeGroupNameRequired
              : null,
      maxLength: 100,
    );
  }
}

class SizeGroupDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const SizeGroupDescriptionField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: AppStrings.adminSizeGroupDescriptionLabel,
        border: OutlineInputBorder(),
      ),
      maxLength: 255,
      maxLines: 2,
    );
  }
}

class SizeGroupSaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SizeGroupSaveButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
      ),
      child: Text(
        AppStrings.adminSizeGroupSave,
        style: GoogleFonts.inter(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.submitButtonFontSize,
        ),
      ),
    );
  }
}
