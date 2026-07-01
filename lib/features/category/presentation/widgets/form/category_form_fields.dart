import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';

class CategoryFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController imageUrlController;
  final TextEditingController displayOrderController;
  final List<CategoryEntity> parentOptions;
  final int? parentId;
  final bool isActive;
  final bool isCustomizable;
  final ValueChanged<int?> onParentChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onCustomizableChanged;

  const CategoryFormFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.imageUrlController,
    required this.displayOrderController,
    required this.parentOptions,
    required this.parentId,
    required this.isActive,
    required this.isCustomizable,
    required this.onParentChanged,
    required this.onActiveChanged,
    required this.onCustomizableChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel(AppStrings.categoryNameLabel),
        TextFormField(
          controller: nameController,
          decoration: _decoration(AppStrings.categoryNameHint),
          maxLength: 100,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return AppStrings.categoryNameRequired;
            if (trimmed.length < 2) return AppStrings.categoryNameMinLength;
            return null;
          },
        ),
        const _FieldLabel(AppStrings.categoryDescriptionLabel),
        TextFormField(
          controller: descriptionController,
          decoration: _decoration(AppStrings.categoryDescriptionHint),
          maxLines: 3,
        ),
        SizedBox(height: AppSizes.paddingMd),
        const _FieldLabel(AppStrings.categoryParentLabel),
        DropdownButtonFormField<int?>(
          initialValue: parentId,
          decoration: _decoration(AppStrings.categoryParentNone),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(AppStrings.categoryParentNone),
            ),
            ...parentOptions.map(
              (parent) => DropdownMenuItem<int?>(
                value: parent.id,
                child: Text(parent.name, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: onParentChanged,
        ),
        const _FieldLabel(AppStrings.categoryImageLabel),
        TextFormField(
          controller: imageUrlController,
          decoration: _decoration(AppStrings.categoryImageHint),
          keyboardType: TextInputType.url,
        ),
        const _FieldLabel(AppStrings.categoryDisplayOrderLabel),
        TextFormField(
          controller: displayOrderController,
          decoration: _decoration(AppStrings.categoryDisplayOrderHint),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        SizedBox(height: AppSizes.paddingSm),
        CategoryStatusSwitch(
          title: AppStrings.categoryStatusActiveTitle,
          subtitle: AppStrings.categoryStatusActiveSubtitle,
          value: isActive,
          onChanged: onActiveChanged,
        ),
        CategoryStatusSwitch(
          title: AppStrings.categoryCustomizableTitle,
          subtitle: AppStrings.categoryCustomizableSubtitle,
          value: isCustomizable,
          onChanged: onCustomizableChanged,
        ),
      ],
    );
  }
}

class CategoryStatusSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CategoryStatusSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.spacing10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.borderGray.withValues(alpha: 0.3),
        ),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        activeThumbColor: AppColors.success,
        onChanged: onChanged,
        title: Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppSizes.spacing12, bottom: AppSizes.spacing6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: AppSizes.font13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

InputDecoration _decoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle:
        GoogleFonts.inter(fontSize: AppSizes.fontLg, color: AppColors.textHint),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing14, vertical: AppSizes.spacing14),
    border: _fieldBorder(),
    enabledBorder: _fieldBorder(),
    focusedBorder: _fieldBorder(color: AppColors.primary, width: 1.5),
  );
}

OutlineInputBorder _fieldBorder({
  Color color = AppColors.divider,
  double width = 1,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
    borderSide: BorderSide(color: color, width: width),
  );
}

