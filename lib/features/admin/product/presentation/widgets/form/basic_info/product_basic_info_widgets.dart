import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';

typedef ProductCategoryOption = ({int id, String label});

class ProductBasicNameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ProductBasicNameField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: AppStrings.adminProductBasicNameLabel,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: (value) => value == null || value.trim().isEmpty
            ? AppStrings.adminProductBasicNameRequired
            : null,
      );
}

class ProductBasicDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ProductBasicDescriptionField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: AppStrings.adminProductBasicDescriptionLabel,
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        onChanged: onChanged,
      );
}

class ProductBasicCategoryDropdown extends StatelessWidget {
  final int? selectedCategoryId;
  final List<ProductCategoryOption> categories;
  final ValueChanged<int> onChanged;

  const ProductBasicCategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
        initialValue:
            categories.any((category) => category.id == selectedCategoryId)
                ? selectedCategoryId
                : null,
        decoration: const InputDecoration(
          labelText: AppStrings.adminProductBasicCategoryLabel,
          border: OutlineInputBorder(),
        ),
        isExpanded: true,
        items: categories
            .map(
              (category) => DropdownMenuItem<int>(
                value: category.id,
                child: Text(
                  category.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        validator: (value) =>
            value == null ? AppStrings.adminProductBasicCategoryRequired : null,
      );
}

class ProductBasicBrandDropdown extends StatelessWidget {
  final AdminProductFormState state;
  final ValueChanged<int> onChanged;

  const ProductBasicBrandDropdown({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
        initialValue: state.brands.any((brand) => brand.id == state.brandId)
            ? state.brandId
            : null,
        decoration: const InputDecoration(
          labelText: AppStrings.adminProductBasicBrandLabel,
          border: OutlineInputBorder(),
        ),
        isExpanded: true,
        items: state.brands
            .where((brand) => brand.id != null)
            .map(
              (brand) => DropdownMenuItem<int>(
                value: brand.id!,
                child: Text(brand.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        validator: (value) =>
            value == null ? AppStrings.adminProductBasicBrandRequired : null,
      );
}

class ProductBasicSizeGroupDropdown extends StatelessWidget {
  final AdminProductFormState state;
  final ValueChanged<int?> onChanged;

  const ProductBasicSizeGroupDropdown({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final groups = state.sizeGroups;
    return DropdownButtonFormField<int?>(
      initialValue: groups.any((group) => group.id == state.sizeGroupId)
          ? state.sizeGroupId
          : null,
      decoration: const InputDecoration(
        labelText: AppStrings.adminProductBasicSizeGroupLabel,
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text(AppStrings.adminProductBasicNoSizeGroup),
        ),
        ...groups.map(
          (group) => DropdownMenuItem<int?>(
            value: group.id,
            child: Text(group.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class ProductBasicGenderDropdown extends StatelessWidget {
  final Gender? gender;
  final ValueChanged<Gender> onChanged;

  const ProductBasicGenderDropdown({
    super.key,
    required this.gender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<Gender>(
        initialValue: gender,
        decoration: const InputDecoration(
          labelText: AppStrings.adminProductBasicGenderLabel,
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(
            value: Gender.male,
            child: Text(AppStrings.adminProductBasicGenderMale),
          ),
          DropdownMenuItem(
            value: Gender.female,
            child: Text(AppStrings.adminProductBasicGenderFemale),
          ),
          DropdownMenuItem(
            value: Gender.unisex,
            child: Text(AppStrings.adminProductBasicGenderUnisex),
          ),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        validator: (value) =>
            value == null ? AppStrings.adminProductBasicGenderRequired : null,
      );
}

class ProductBasicStatusDropdown extends StatelessWidget {
  final ProductStatus status;
  final ValueChanged<ProductStatus> onChanged;

  const ProductBasicStatusDropdown({
    super.key,
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<ProductStatus>(
        initialValue: status,
        decoration: const InputDecoration(
          labelText: AppStrings.adminProductBasicStatusLabel,
          border: OutlineInputBorder(),
        ),
        items: ProductStatus.values
            .where((status) => status != ProductStatus.deleted)
            .map(
              (status) => DropdownMenuItem(
                value: status,
                child: Text(
                  status == ProductStatus.active
                      ? AppStrings.adminProductVariantStatusActive
                      : AppStrings.adminProductVariantStatusInactive,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      );
}

class ProductBasicFeaturedSwitch extends StatelessWidget {
  final bool value;
  final VoidCallback onToggle;

  const ProductBasicFeaturedSwitch({
    super.key,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(AppStrings.adminProductBasicFeaturedTitle),
        subtitle: const Text(AppStrings.adminProductBasicFeaturedSubtitle),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: (_) => onToggle(),
      );
}

class ProductBasicNextButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const ProductBasicNextButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingSm + 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: AppSizes.iconMd,
                width: AppSizes.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                AppStrings.adminProductBasicNext,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
      );
}
