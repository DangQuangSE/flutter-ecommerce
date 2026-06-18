import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/bulk_variant_sheet.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/variant_edit_dialog.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_state.dart';

class ProductFormStep2Variants extends StatefulWidget {
  final AdminProductFormState formState;
  final AdminProductFormCubit formCubit;

  const ProductFormStep2Variants({
    super.key,
    required this.formState,
    required this.formCubit,
  });

  @override
  State<ProductFormStep2Variants> createState() =>
      _ProductFormStep2VariantsState();
}

class _ProductFormStep2VariantsState extends State<ProductFormStep2Variants> {
  bool _showAddForm = false;
  bool _isSubmittingVariant = false;

  final _addFormKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _sizeController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockController = TextEditingController();
  int? _selectedColorId;
  ProductStatus _selectedStatus = ProductStatus.active;

  @override
  void dispose() {
    _skuController.dispose();
    _sizeController.dispose();
    _originalPriceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _clearAddForm() {
    _skuController.clear();
    _sizeController.clear();
    _originalPriceController.clear();
    _salePriceController.clear();
    _stockController.clear();
    setState(() {
      _selectedColorId = null;
      _selectedStatus = ProductStatus.active;
      _showAddForm = false;
      _isSubmittingVariant = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productId = widget.formState.resolvedProductId;

    return BlocConsumer<AdminProductVariantCubit, AdminProductVariantState>(
      listener: (context, state) {
        if (state is AdminProductVariantFailure) {
          setState(() => _isSubmittingVariant = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ));
        }
        if (state is AdminProductVariantSuccess && _isSubmittingVariant) {
          _clearAddForm();
        }
      },
      builder: (context, variantState) {
        final variants = variantState is AdminProductVariantSuccess
            ? variantState.variants
            : <ProductVariantEntity>[];
        final isLoading = variantState is AdminProductVariantLoading;
        final variantCubit = context.read<AdminProductVariantCubit>();

        return Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (variants.isEmpty && !_showAddForm)
                            _buildEmptyPlaceholder(productId),
                          ...variants.map((v) =>
                              _buildVariantRow(context, variantCubit, v)),
                          if (_showAddForm)
                            BlocBuilder<ProductColorCubit, ProductColorState>(
                              builder: (context, colorState) {
                                final colors = colorState is ProductColorLoaded
                                    ? colorState.colors
                                        .where((c) => c.id != null)
                                        .toList()
                                    : <ProductColorEntity>[];
                                return _buildAddForm(
                                    context, variantCubit, colors, productId);
                              },
                            ),
                          if (!_showAddForm && productId != null)
                            BlocBuilder<ProductColorCubit, ProductColorState>(
                              builder: (context, colorState) {
                                final colors = colorState is ProductColorLoaded
                                    ? colorState.colors
                                        .where((c) => c.id != null)
                                        .toList()
                                    : <ProductColorEntity>[];
                                return _buildVariantActionButtons(
                                    context, variantCubit, colors, productId);
                              },
                            ),
                          if (productId == null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.warning),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: AppColors.warning, size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Hoàn tất thông tin cơ bản ở Bước 1 trước khi thêm biến thể.',
                                      style: TextStyle(
                                          color: AppColors.warning,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            _buildNavButtons(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyPlaceholder(int? productId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text(
            'Chưa có biến thể nào',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          if (productId != null) ...[
            const SizedBox(height: 6),
            const Text(
              'Nhấn "Thêm biến thể" để thêm mới',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariantRow(BuildContext context,
      AdminProductVariantCubit variantCubit, ProductVariantEntity variant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(variant.sku,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(variant.salePrice != null
            ? '${variant.size} · ${variant.colorName} · ${_formatPrice(variant.originalPrice)} (Sale: ${_formatPrice(variant.salePrice!)})'
            : '${variant.size} · ${variant.colorName} · ${_formatPrice(variant.originalPrice)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${variant.stockQuantity} cái',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () => _onEditVariant(context, variantCubit, variant),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              onPressed: () => variantCubit.deleteVariant(variant.id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onEditVariant(
    BuildContext context,
    AdminProductVariantCubit variantCubit,
    ProductVariantEntity variant,
  ) async {
    final result = await showVariantEditDialog(
      context,
      title: 'Sửa: ${variant.sku}',
      initialPrice: variant.originalPrice,
      initialSalePrice: variant.salePrice,
      initialStock: variant.stockQuantity,
      initialStatus: variant.status,
    );
    if (result != null && context.mounted) {
      variantCubit.updateVariant(
        variant.id,
        CreateVariantParams(
          sku: variant.sku,
          size: variant.size,
          colorId: variant.colorId,
          originalPrice: result.originalPrice,
          salePrice: result.salePrice,
          stockQuantity: result.stockQuantity,
          status: result.status,
        ),
      );
    }
  }

  Widget _buildAddForm(
    BuildContext context,
    AdminProductVariantCubit variantCubit,
    List<ProductColorEntity> colors,
    int? productId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _addFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Thêm biến thể',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),

              // Color dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Màu sắc *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                isExpanded: true,
                items: colors
                    .map((c) => DropdownMenuItem<int>(
                          value: c.id!,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _parseHex(c.hexCode),
                                  border: Border.all(color: AppColors.divider),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(c.name,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedColorId = v),
                validator: (v) => v == null ? 'Vui lòng chọn màu sắc' : null,
              ),
              const SizedBox(height: 12),

              // Size + SKU row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sizeController,
                      decoration: const InputDecoration(
                        labelText: 'Kích thước *',
                        hintText: 'S, M, L...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Price row
              TextFormField(
                controller: _originalPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Giá gốc *',
                  border: OutlineInputBorder(),
                  isDense: true,
                  suffixText: '₫',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                  if (double.tryParse(v.trim()) == null) {
                    return 'Không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _salePriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Giá sale',
                  border: OutlineInputBorder(),
                  isDense: true,
                  suffixText: '₫',
                ),
                validator: (v) {
                  if (v != null &&
                      v.trim().isNotEmpty &&
                      double.tryParse(v.trim()) == null) {
                    return 'Không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Stock + Status row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tồn kho *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                        if (int.tryParse(v.trim()) == null) {
                          return 'Phải là số nguyên';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ProductStatus>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: ProductStatus.values
                          .where((s) => s != ProductStatus.deleted)
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s == ProductStatus.active
                                    ? 'Đang bán'
                                    : 'Tạm ẩn'),
                              ))
                          .toList(),
                      onChanged: (s) {
                        if (s != null) setState(() => _selectedStatus = s);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAddForm,
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (productId == null || _isSubmittingVariant)
                          ? null
                          : () {
                              if (_addFormKey.currentState!.validate()) {
                                setState(() => _isSubmittingVariant = true);
                                variantCubit.createVariant(
                                  productId,
                                  CreateVariantParams(
                                    sku: _skuController.text.trim(),
                                    size: _sizeController.text.trim(),
                                    colorId: _selectedColorId!,
                                    originalPrice: double.parse(
                                        _originalPriceController.text.trim()),
                                    salePrice:
                                        _salePriceController.text.trim().isEmpty
                                            ? null
                                            : double.parse(
                                                _salePriceController.text
                                                    .trim()),
                                    stockQuantity:
                                        int.parse(_stockController.text.trim()),
                                    status: _selectedStatus,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmittingVariant
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Thêm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariantActionButtons(
    BuildContext context,
    AdminProductVariantCubit variantCubit,
    List<ProductColorEntity> colors,
    int productId,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  _showBulkSheet(context, variantCubit, colors, productId),
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Tạo hàng loạt'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showAddForm = true),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Thêm 1 biến thể'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBulkSheet(
    BuildContext context,
    AdminProductVariantCubit variantCubit,
    List<ProductColorEntity> colors,
    int productId,
  ) async {
    final drafts = await showModalBottomSheet<List<CreateVariantParams>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => BulkVariantSheet(
          productId: productId,
          sizeGroups: widget.formState.sizeGroups,
          preSelectedSizeGroupId: widget.formState.sizeGroupId,
          colors: colors,
          productName: widget.formState.name,
          brandName: widget.formState.brands
                  .where((b) => b.id == widget.formState.brandId)
                  .firstOrNull
                  ?.name ??
              '',
        ),
      ),
    );

    if (drafts != null && drafts.isNotEmpty && context.mounted) {
      variantCubit.createVariantsBatch(productId, drafts);
    }
  }

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.formCubit.goBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Quay lại'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => widget.formCubit.advanceToStep(2),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Tiếp theo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M₫';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K₫';
    }
    return '${price.toStringAsFixed(0)}₫';
  }

  Color _parseHex(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      if (h.length != 6) return Colors.grey;
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}
