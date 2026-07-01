import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/bulk_variant/bulk_variant_sheet.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/form/variants/product_variant_actions.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/form/variants/product_variant_add_form.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/form/variants/product_variant_list_widgets.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/shared/variant_edit_dialog.dart';
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
          AppSnackBar.show(
            context,
            message: state.message,
            type: AppSnackBarType.error,
          );
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
                  ? const AppLoadingView()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.paddingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (variants.isEmpty && !_showAddForm)
                            AdminVariantEmptyPlaceholder(
                              canAddVariant: productId != null,
                            ),
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
                                return AdminVariantAddForm(
                                  formKey: _addFormKey,
                                  skuController: _skuController,
                                  sizeController: _sizeController,
                                  originalPriceController:
                                      _originalPriceController,
                                  salePriceController: _salePriceController,
                                  stockController: _stockController,
                                  colors: colors,
                                  productId: productId,
                                  selectedColorId: _selectedColorId,
                                  selectedStatus: _selectedStatus,
                                  isSubmitting: _isSubmittingVariant,
                                  onColorChanged: (value) =>
                                      setState(() => _selectedColorId = value),
                                  onStatusChanged: (status) =>
                                      setState(() => _selectedStatus = status),
                                  onCancel: _clearAddForm,
                                  onSubmit: () =>
                                      _submitVariant(variantCubit, productId),
                                );
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
                                return AdminVariantActionButtons(
                                  onBulkCreate: () => _showBulkSheet(
                                    context,
                                    variantCubit,
                                    colors,
                                    productId,
                                  ),
                                  onAddOne: () =>
                                      setState(() => _showAddForm = true),
                                );
                              },
                            ),
                          if (productId == null)
                            const AdminVariantBasicInfoWarning(),
                        ],
                      ),
                    ),
            ),
            AdminVariantNavigation(
              onBack: widget.formCubit.goBack,
              onNext: () => widget.formCubit.advanceToStep(2),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVariantRow(BuildContext context,
      AdminProductVariantCubit variantCubit, ProductVariantEntity variant) {
    final salePrice = variant.salePrice;
    return AdminVariantRow(
      variant: variant,
      subtitle: AppStrings.adminProductVariantSubtitle(
        size: variant.size,
        colorName: variant.colorName,
        price: _formatPrice(variant.originalPrice),
        salePrice: salePrice == null ? null : _formatPrice(salePrice),
      ),
      onEdit: () => _onEditVariant(context, variantCubit, variant),
      onDelete: () => variantCubit.deleteVariant(variant.id),
    );
  }

  Future<void> _onEditVariant(
    BuildContext context,
    AdminProductVariantCubit variantCubit,
    ProductVariantEntity variant,
  ) async {
    final result = await showVariantEditDialog(
      context,
      title: AppStrings.adminProductVariantEditTitle(variant.sku),
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

  void _submitVariant(
    AdminProductVariantCubit variantCubit,
    int? productId,
  ) {
    if (productId == null) return;
    setState(() => _isSubmittingVariant = true);
    variantCubit.createVariant(
      productId,
      CreateVariantParams(
        sku: _skuController.text.trim(),
        size: _sizeController.text.trim(),
        colorId: _selectedColorId!,
        originalPrice: double.parse(_originalPriceController.text.trim()),
        salePrice: _salePriceController.text.trim().isEmpty
            ? null
            : double.parse(_salePriceController.text.trim()),
        stockQuantity: int.parse(_stockController.text.trim()),
        status: _selectedStatus,
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
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

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M${AppStrings.adminProductVariantPriceSuffix}';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K${AppStrings.adminProductVariantPriceSuffix}';
    }
    return '${price.toStringAsFixed(0)}${AppStrings.adminProductVariantPriceSuffix}';
  }
}
