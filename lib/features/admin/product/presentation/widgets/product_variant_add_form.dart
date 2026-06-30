import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';

class AdminVariantAddForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController skuController;
  final TextEditingController sizeController;
  final TextEditingController originalPriceController;
  final TextEditingController salePriceController;
  final TextEditingController stockController;
  final List<ProductColorEntity> colors;
  final int? productId;
  final int? selectedColorId;
  final ProductStatus selectedStatus;
  final bool isSubmitting;
  final ValueChanged<int?> onColorChanged;
  final ValueChanged<ProductStatus> onStatusChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const AdminVariantAddForm({
    super.key,
    required this.formKey,
    required this.skuController,
    required this.sizeController,
    required this.originalPriceController,
    required this.salePriceController,
    required this.stockController,
    required this.colors,
    required this.productId,
    required this.selectedColorId,
    required this.selectedStatus,
    required this.isSubmitting,
    required this.onColorChanged,
    required this.onStatusChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppStrings.adminProductVariantAddTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.submitButtonFontSize,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSm + 4),
                _VariantColorField(
                  colors: colors,
                  value: selectedColorId,
                  onChanged: onColorChanged,
                ),
                const SizedBox(height: AppSizes.paddingSm + 4),
                _SizeSkuRow(
                  sizeController: sizeController,
                  skuController: skuController,
                ),
                const SizedBox(height: AppSizes.paddingSm + 4),
                _PriceField(
                  controller: originalPriceController,
                  label: AppStrings.adminProductBulkOriginalPrice,
                  required: true,
                ),
                const SizedBox(height: AppSizes.paddingSm + 4),
                _PriceField(
                  controller: salePriceController,
                  label: AppStrings.adminProductBulkSalePrice,
                ),
                const SizedBox(height: AppSizes.paddingSm + 4),
                _StockStatusRow(
                  stockController: stockController,
                  selectedStatus: selectedStatus,
                  onStatusChanged: onStatusChanged,
                ),
                const SizedBox(height: AppSizes.paddingMd),
                _AddFormActions(
                  productId: productId,
                  isSubmitting: isSubmitting,
                  onCancel: onCancel,
                  onSubmit: () {
                    if (formKey.currentState!.validate()) {
                      onSubmit();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
}

class _VariantColorField extends StatelessWidget {
  final List<ProductColorEntity> colors;
  final int? value;
  final ValueChanged<int?> onChanged;

  const _VariantColorField({
    required this.colors,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
        initialValue: value,
        decoration: const InputDecoration(
          labelText: AppStrings.adminProductVariantColorLabel,
          border: OutlineInputBorder(),
          isDense: true,
        ),
        isExpanded: true,
        items: colors
            .map(
              (color) => DropdownMenuItem<int>(
                value: color.id!,
                child: Row(
                  children: [
                    Container(
                      width: AppSizes.iconSm,
                      height: AppSizes.iconSm,
                      margin: const EdgeInsets.only(right: AppSizes.paddingSm),
                      decoration: BoxDecoration(
                        color: _parseHex(color.hexCode),
                        border: Border.all(color: AppColors.divider),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        color.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null ? AppStrings.adminProductVariantColorRequired : null,
      );
}

class _SizeSkuRow extends StatelessWidget {
  final TextEditingController sizeController;
  final TextEditingController skuController;

  const _SizeSkuRow({
    required this.sizeController,
    required this.skuController,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: sizeController,
              decoration: const InputDecoration(
                labelText: AppStrings.adminProductVariantSizeLabel,
                hintText: AppStrings.adminProductVariantSizeHint,
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: _requiredValidator,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSm + 4),
          Expanded(
            child: TextFormField(
              controller: skuController,
              decoration: const InputDecoration(
                labelText: AppStrings.adminProductVariantSkuLabel,
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: _requiredValidator,
            ),
          ),
        ],
      );
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;

  const _PriceField({
    required this.controller,
    required this.label,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixText: AppStrings.adminProductVariantPriceSuffix,
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (required && text.isEmpty) {
            return AppStrings.adminProductBulkRequired;
          }
          if (text.isNotEmpty && double.tryParse(text) == null) {
            return AppStrings.adminProductBulkInvalid;
          }
          return null;
        },
      );
}

class _StockStatusRow extends StatelessWidget {
  final TextEditingController stockController;
  final ProductStatus selectedStatus;
  final ValueChanged<ProductStatus> onStatusChanged;

  const _StockStatusRow({
    required this.stockController,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.adminProductBulkStock,
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return AppStrings.adminProductBulkRequired;
                if (int.tryParse(text) == null) {
                  return AppStrings.adminProductBulkInteger;
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: AppSizes.paddingSm + 4),
          Expanded(
            child: DropdownButtonFormField<ProductStatus>(
              initialValue: selectedStatus,
              decoration: const InputDecoration(
                labelText: AppStrings.adminProductVariantStatusLabel,
                border: OutlineInputBorder(),
                isDense: true,
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
              onChanged: (status) {
                if (status != null) {
                  onStatusChanged(status);
                }
              },
            ),
          ),
        ],
      );
}

class _AddFormActions extends StatelessWidget {
  final int? productId;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _AddFormActions({
    required this.productId,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text(AppStrings.cancel),
            ),
          ),
          const SizedBox(width: AppSizes.paddingSm + 4),
          Expanded(
            child: ElevatedButton(
              onPressed: (productId == null || isSubmitting) ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: AppSizes.iconSm + 2,
                      width: AppSizes.iconSm + 2,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(AppStrings.adminProductVariantAdd),
            ),
          ),
        ],
      );
}

String? _requiredValidator(String? value) =>
    value == null || value.trim().isEmpty
        ? AppStrings.adminProductBulkRequired
        : null;

Color _parseHex(String hex) {
  try {
    final value = hex.replaceAll('#', '');
    if (value.length != 6) return Colors.grey;
    return Color(int.parse('FF$value', radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}
