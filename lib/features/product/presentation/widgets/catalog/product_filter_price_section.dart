import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_section_title.dart';

class ProductFilterPriceSection extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final void Function(double? min, double? max) onPreset;

  const ProductFilterPriceSection({
    super.key,
    required this.minController,
    required this.maxController,
    required this.onPreset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProductFilterSectionTitle(AppStrings.productFilterPriceRange),
        Row(
          children: [
            Expanded(
              child: _PriceField(
                controller: minController,
                label: AppStrings.productFilterMinPrice,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSm),
              child: Text('-', style: TextStyle(fontSize: AppSizes.fontXxl)),
            ),
            Expanded(
              child: _PriceField(
                controller: maxController,
                label: AppStrings.productFilterMaxPrice,
              ),
            ),
          ],
        ),
        AppSizes.spacingMd,
        Wrap(
          spacing: AppSizes.paddingSm,
          children: [
            _PresetChip(
              label: AppStrings.productFilterUnderOneMillion,
              onTap: () => onPreset(null, 1000000),
            ),
            _PresetChip(
              label: AppStrings.productFilterOneToThreeMillion,
              onTap: () => onPreset(1000000, 3000000),
            ),
          ],
        ),
        AppSizes.spacingMd,
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PriceField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        suffixText: AppStrings.productFilterCurrencySuffix,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.radiusMd,
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.radiusSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
