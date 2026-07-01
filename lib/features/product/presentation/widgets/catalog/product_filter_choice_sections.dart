import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/utils/product_constants.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_section_title.dart';

class ProductFilterBrandSection extends StatelessWidget {
  final List<BrandEntity> brands;
  final bool loading;
  final String? error;
  final int? selectedId;
  final void Function(int? id, String? name) onSelect;

  const ProductFilterBrandSection({
    super.key,
    required this.brands,
    required this.loading,
    this.error,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProductFilterSectionTitle(AppStrings.productFilterBrand),
        if (loading)
          const AppLoadingView(size: AppSizes.paddingXl)
        else if (error != null)
          Text(error!, style: TextStyle(color: AppColors.error))
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 140),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: AppSizes.paddingSm,
                runSpacing: AppSizes.paddingSm,
                children: brands
                    .map(
                      (brand) => _BrandChip(
                        brand: brand,
                        selected: selectedId == brand.id,
                        onSelect: onSelect,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        const Divider(),
      ],
    );
  }
}

class _BrandChip extends StatelessWidget {
  final BrandEntity brand;
  final bool selected;
  final void Function(int? id, String? name) onSelect;

  const _BrandChip({
    required this.brand,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        final id = brand.id;
        if (id == null) return;
        selected ? onSelect(null, null) : onSelect(id, brand.name);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.radiusSm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E293B) : AppColors.background),
          borderRadius: BorderRadius.circular(AppSizes.paddingSm),
          border: Border.all(
            color: selected ? AppColors.primary : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          brand.name,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class ProductFilterGenderSection extends StatelessWidget {
  final String? selected;
  final void Function(String? gender) onSelect;

  const ProductFilterGenderSection({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      _FilterOption(null, AppStrings.productFilterAll),
      _FilterOption('MALE', AppStrings.productFilterMale),
      _FilterOption('FEMALE', AppStrings.productFilterFemale),
      _FilterOption('UNISEX', AppStrings.productFilterUnisex),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProductFilterSectionTitle(AppStrings.productFilterGender),
        Row(
          children: options
              .map(
                (option) => Expanded(
                  child: _SelectableTextChip(
                    label: option.label,
                    selected: selected == option.value,
                    onTap: () => onSelect(option.value),
                  ),
                ),
              )
              .toList(),
        ),
        AppSizes.spacingSm,
        const Divider(),
      ],
    );
  }
}

class ProductFilterColorSection extends StatelessWidget {
  final String? selected;
  final void Function(String? color) onSelect;

  const ProductFilterColorSection({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProductFilterSectionTitle(AppStrings.productFilterColor),
        Wrap(
          spacing: AppSizes.paddingMd,
          runSpacing: AppSizes.paddingMd,
          children: productColorMap.entries
              .map(
                (entry) => _ColorChip(
                  colorKey: entry.key,
                  color: entry.value,
                  selected: selected == entry.key,
                  onSelect: onSelect,
                ),
              )
              .toList(),
        ),
        AppSizes.spacingMd,
        const Divider(),
      ],
    );
  }
}

class _SelectableTextChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableTextChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSizes.paddingSm),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E293B) : AppColors.background),
          borderRadius: BorderRadius.circular(AppSizes.paddingSm),
          border: Border.all(
            color: selected ? AppColors.primary : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String colorKey;
  final Color color;
  final bool selected;
  final ValueChanged<String?> onSelect;

  const _ColorChip({
    required this.colorKey,
    required this.color,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(selected ? null : colorKey),
      child: Container(
        width: AppSizes.colorSwatchSize,
        height: AppSizes.colorSwatchSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: AppSizes.radiusSm,
                  ),
                ]
              : null,
        ),
        child: selected
            ? Icon(
                Icons.check,
                size: AppSizes.fontXl,
                color: AppColors.white,
              )
            : null,
      ),
    );
  }
}

class _FilterOption {
  final String? value;
  final String label;

  const _FilterOption(this.value, this.label);
}
