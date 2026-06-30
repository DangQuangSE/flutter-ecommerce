import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class VariantEditResult {
  final String? sku;
  final double originalPrice;
  final double? salePrice;
  final int stockQuantity;
  final ProductStatus status;

  const VariantEditResult({
    this.sku,
    required this.originalPrice,
    this.salePrice,
    required this.stockQuantity,
    required this.status,
  });
}

Future<VariantEditResult?> showVariantEditDialog(
  BuildContext context, {
  required String title,
  String? initialSku,
  required double initialPrice,
  double? initialSalePrice,
  required int initialStock,
  required ProductStatus initialStatus,
  bool showStatus = true,
}) {
  return showDialog<VariantEditResult>(
    context: context,
    builder: (ctx) => _VariantEditDialogContent(
      title: title,
      initialSku: initialSku,
      initialPrice: initialPrice,
      initialSalePrice: initialSalePrice,
      initialStock: initialStock,
      initialStatus: initialStatus,
      showStatus: showStatus,
    ),
  );
}

class _VariantEditDialogContent extends StatefulWidget {
  final String title;
  final String? initialSku;
  final double initialPrice;
  final double? initialSalePrice;
  final int initialStock;
  final ProductStatus initialStatus;
  final bool showStatus;

  const _VariantEditDialogContent({
    required this.title,
    this.initialSku,
    required this.initialPrice,
    required this.initialSalePrice,
    required this.initialStock,
    required this.initialStatus,
    required this.showStatus,
  });

  @override
  State<_VariantEditDialogContent> createState() =>
      _VariantEditDialogContentState();
}

class _VariantEditDialogContentState extends State<_VariantEditDialogContent> {
  TextEditingController? _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockController;
  late ProductStatus _status;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialSku != null) {
      _skuController = TextEditingController(text: widget.initialSku);
    }
    _priceController = TextEditingController(
      text: widget.initialPrice.toStringAsFixed(0),
    );
    _salePriceController = TextEditingController(
      text: widget.initialSalePrice?.toStringAsFixed(0) ?? '',
    );
    _stockController =
        TextEditingController(text: widget.initialStock.toString());
    _status = widget.initialStatus;
  }

  @override
  void dispose() {
    _skuController?.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final salePriceText = _salePriceController.text.trim();
    Navigator.pop(
      context,
      VariantEditResult(
        sku: _skuController?.text.trim(),
        originalPrice: double.parse(_priceController.text.trim()),
        salePrice: salePriceText.isEmpty ? null : double.parse(salePriceText),
        stockQuantity: int.parse(_stockController.text.trim()),
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: AppSizes.fontXl),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_skuController != null) ...[
                _SkuField(controller: _skuController!),
                const SizedBox(height: AppSizes.paddingSm + AppSizes.paddingXs),
              ],
              _PriceField(
                controller: _priceController,
                label: AppStrings.adminProductBulkOriginalPrice,
                required: true,
              ),
              const SizedBox(height: AppSizes.paddingSm + AppSizes.paddingXs),
              _PriceField(
                controller: _salePriceController,
                label: AppStrings.adminProductBulkSalePrice,
                required: false,
              ),
              const SizedBox(height: AppSizes.paddingSm + AppSizes.paddingXs),
              _StockField(controller: _stockController),
              if (widget.showStatus) ...[
                const SizedBox(height: AppSizes.paddingSm + AppSizes.paddingXs),
                _StatusDropdown(
                  value: _status,
                  onChanged: (status) => setState(() => _status = status),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}

class _SkuField extends StatelessWidget {
  final TextEditingController controller;

  const _SkuField({required this.controller});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: AppStrings.adminProductVariantSkuLabel,
          border: OutlineInputBorder(),
          isDense: true,
        ),
        validator: _requiredValidator,
      );
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;

  const _PriceField({
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
          suffixText: AppStrings.adminProductVariantPriceSuffix,
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

class _StockField extends StatelessWidget {
  final TextEditingController controller;

  const _StockField({required this.controller});

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
          final requiredMessage = _requiredValidator(value);
          if (requiredMessage != null) return requiredMessage;
          if (int.tryParse(value!.trim()) == null) {
            return AppStrings.adminProductBulkInteger;
          }
          return null;
        },
      );
}

class _StatusDropdown extends StatelessWidget {
  final ProductStatus value;
  final ValueChanged<ProductStatus> onChanged;

  const _StatusDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<ProductStatus>(
        initialValue: value,
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
          if (status != null) onChanged(status);
        },
      );
}

String? _requiredValidator(String? value) =>
    value == null || value.trim().isEmpty
        ? AppStrings.adminProductBulkRequired
        : null;
