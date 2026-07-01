import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/bulk_variant/bulk_variant_helpers.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';

class BulkVariantSizeGroupDropdown extends StatelessWidget {
  final List<SizeGroupEntity> sizeGroups;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const BulkVariantSizeGroupDropdown({
    super.key,
    required this.sizeGroups,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BulkVariantSectionLabel(
            AppStrings.adminProductBulkSizeGroupStep,
          ),
          SizedBox(height: AppSizes.paddingSm),
          DropdownButtonFormField<int>(
            initialValue: selectedId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              hintText: AppStrings.adminProductBulkSizeGroupHint,
            ),
            isExpanded: true,
            items: sizeGroups
                .where((group) => group.id != null)
                .map(
                  (group) => DropdownMenuItem(
                    value: group.id!,
                    child: Text(group.name),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            validator: (value) => value == null
                ? AppStrings.adminProductBulkSizeGroupRequired
                : null,
          ),
        ],
      );
}

class BulkVariantSizeChipsSection extends StatelessWidget {
  final List<String> sizes;
  final Set<String> selectedSizes;
  final ValueChanged<String> onToggle;

  const BulkVariantSizeChipsSection({
    super.key,
    required this.sizes,
    required this.selectedSizes,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BulkVariantSectionLabel(AppStrings.adminProductBulkSizeStep),
          SizedBox(height: AppSizes.paddingSm),
          Wrap(
            spacing: AppSizes.paddingSm,
            runSpacing: AppSizes.paddingSm,
            children: sizes.map((size) {
              final selected = selectedSizes.contains(size);
              return FilterChip(
                label: Text(size),
                selected: selected,
                onSelected: (_) => onToggle(size),
                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.divider,
                ),
              );
            }).toList(),
          ),
        ],
      );
}

class BulkVariantColorCheckboxSection extends StatelessWidget {
  final List<ProductColorEntity> colors;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;

  const BulkVariantColorCheckboxSection({
    super.key,
    required this.colors,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final validColors = colors.where((color) => color.id != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BulkVariantSectionLabel(AppStrings.adminProductBulkColorStep),
        SizedBox(height: AppSizes.paddingSm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: AppSizes.paddingSm,
            mainAxisSpacing: AppSizes.paddingSm,
          ),
          itemCount: validColors.length,
          itemBuilder: (_, index) {
            final color = validColors[index];
            return _ColorTile(
              color: color,
              selected: selectedIds.contains(color.id!),
              onTap: () => onToggle(color.id!),
            );
          },
        ),
      ],
    );
  }
}

class BulkVariantDefaultValuesSection extends StatelessWidget {
  final TextEditingController originalPriceCtrl;
  final TextEditingController salePriceCtrl;
  final TextEditingController stockCtrl;

  const BulkVariantDefaultValuesSection({
    super.key,
    required this.originalPriceCtrl,
    required this.salePriceCtrl,
    required this.stockCtrl,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BulkVariantSectionLabel(
              AppStrings.adminProductBulkDefaultsStep),
          SizedBox(height: AppSizes.paddingSm),
          Row(
            children: [
              Expanded(
                child: _DefaultPriceField(
                  controller: originalPriceCtrl,
                  label: AppStrings.adminProductBulkOriginalPrice,
                  required: true,
                ),
              ),
              SizedBox(width: AppSizes.paddingSm),
              Expanded(
                child: _DefaultPriceField(
                  controller: salePriceCtrl,
                  label: AppStrings.adminProductBulkSalePrice,
                  required: false,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingSm),
          _DefaultStockField(controller: stockCtrl),
        ],
      );
}

class _ColorTile extends StatelessWidget {
  final ProductColorEntity color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorTile({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXs),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            color: selected ? AppColors.primary.withValues(alpha: 0.06) : null,
          ),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                visualDensity: VisualDensity.compact,
                activeColor: AppColors.primary,
              ),
              Container(
                width: AppSizes.fontLg,
                height: AppSizes.fontLg,
                margin: const EdgeInsets.only(right: AppSizes.paddingXs + 2),
                decoration: BoxDecoration(
                  color: bulkVariantHexColor(color.hexCode),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider),
                ),
              ),
              Expanded(
                child: Text(
                  color.name,
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
}

class _DefaultPriceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;

  const _DefaultPriceField({
    required this.controller,
    required this.label,
    required this.required,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixText: AppStrings.productFilterCurrencySuffix,
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return AppStrings.adminProductBulkRequired;
          }
          if (value != null &&
              value.trim().isNotEmpty &&
              double.tryParse(value.trim()) == null) {
            return AppStrings.adminProductBulkInvalid;
          }
          return null;
        },
      );
}

class _DefaultStockField extends StatelessWidget {
  final TextEditingController controller;

  const _DefaultStockField({required this.controller});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: AppStrings.adminProductBulkStock,
          border: OutlineInputBorder(),
          isDense: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppStrings.adminProductBulkRequired;
          }
          if (int.tryParse(value.trim()) == null) {
            return AppStrings.adminProductBulkInteger;
          }
          return null;
        },
      );
}
