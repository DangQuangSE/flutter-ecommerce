import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
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

/// Shows a dialog to edit variant fields.
/// Pass [initialSku] to show the SKU field (e.g. for preview items).
/// Set [showStatus] to false to hide the status dropdown (default true).
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
    this.initialSalePrice,
    required this.initialStock,
    required this.initialStatus,
    required this.showStatus,
  });

  @override
  State<_VariantEditDialogContent> createState() =>
      _VariantEditDialogContentState();
}

class _VariantEditDialogContentState extends State<_VariantEditDialogContent> {
  TextEditingController? _skuCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _salePriceCtrl;
  late final TextEditingController _stockCtrl;
  late ProductStatus _status;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialSku != null) {
      _skuCtrl = TextEditingController(text: widget.initialSku);
    }
    _priceCtrl =
        TextEditingController(text: widget.initialPrice.toStringAsFixed(0));
    _salePriceCtrl = TextEditingController(
        text: widget.initialSalePrice?.toStringAsFixed(0) ?? '');
    _stockCtrl = TextEditingController(text: widget.initialStock.toString());
    _status = widget.initialStatus;
  }

  @override
  void dispose() {
    _skuCtrl?.dispose();
    _priceCtrl.dispose();
    _salePriceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final salePriceText = _salePriceCtrl.text.trim();
    Navigator.pop(
      context,
      VariantEditResult(
        sku: _skuCtrl?.text.trim(),
        originalPrice: double.parse(_priceCtrl.text.trim()),
        salePrice: salePriceText.isEmpty ? null : double.parse(salePriceText),
        stockQuantity: int.parse(_stockCtrl.text.trim()),
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.title, style: const TextStyle(fontSize: AppSizes.fontXl)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_skuCtrl != null) ...[
                _SkuField(controller: _skuCtrl!),
                const SizedBox(height: AppSizes.paddingSm + AppSizes.paddingXs),
              ],
              _PriceField(
                  controller: _priceCtrl, label: 'Giá gốc *', required: true),
              const SizedBox(height: AppSizes.paddingSm + AppSizes.paddingXs),
              _StockField(controller: _stockCtrl),
              if (widget.showStatus) ...[
                const SizedBox(height: AppSizes.paddingSm + AppSizes.paddingXs),
                _StatusDropdown(
                  value: _status,
                  onChanged: (s) => setState(() => _status = s),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

// ── Form field sub-widgets ────────────────────────────────────────────────────

class _SkuField extends StatelessWidget {
  final TextEditingController controller;
  const _SkuField({required this.controller});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        decoration: const InputDecoration(
            labelText: 'SKU *', border: OutlineInputBorder(), isDense: true),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
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
            suffixText: '₫'),
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return 'Bắt buộc';
          if (v != null &&
              v.trim().isNotEmpty &&
              double.tryParse(v.trim()) == null) {
            return 'Không hợp lệ';
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
            labelText: 'Tồn kho *',
            border: OutlineInputBorder(),
            isDense: true),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Bắt buộc';
          if (int.tryParse(v.trim()) == null) return 'Số nguyên';
          return null;
        },
      );
}

class _StatusDropdown extends StatelessWidget {
  final ProductStatus value;
  final ValueChanged<ProductStatus> onChanged;

  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<ProductStatus>(
        initialValue: value,
        decoration: const InputDecoration(
            labelText: 'Trạng thái',
            border: OutlineInputBorder(),
            isDense: true),
        items: ProductStatus.values
            .where((s) => s != ProductStatus.deleted)
            .map((s) => DropdownMenuItem(
                  value: s,
                  child:
                      Text(s == ProductStatus.active ? 'Đang bán' : 'Tạm ẩn'),
                ))
            .toList(),
        onChanged: (s) {
          if (s != null) onChanged(s);
        },
      );
}
