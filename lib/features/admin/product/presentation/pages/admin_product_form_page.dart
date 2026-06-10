import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_state.dart';

class AdminProductFormPage extends StatelessWidget {
  final int? productId;
  const AdminProductFormPage({super.key, this.productId});

  bool get _isEdit => productId != null;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        if (_isEdit)
          BlocListener<AdminProductDetailCubit, AdminProductDetailState>(
            listener: (context, state) {
              if (state is AdminProductDetailSuccess) {
                // All three are synchronous — they populate in the same listener callback.
                context.read<AdminProductFormCubit>().loadForEdit(state.product);
                context.read<AdminProductVariantCubit>().loadFromDetail(state.product.variants);
                context.read<AdminProductImageCubit>().loadFromDetail(state.product.images);
              } else if (state is AdminProductDetailFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ));
                context.pop();
              }
            },
          ),
        BlocListener<AdminProductFormCubit, AdminProductFormState>(
          listenWhen: (prev, curr) =>
              prev.isSuccess != curr.isSuccess ||
              prev.errorMessage != curr.errorMessage ||
              (_isEdit && prev.currentStep != curr.currentStep && curr.currentStep == 1),
          listener: (context, state) {
            if (state.isSuccess && state.currentStep == 2) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(_isEdit
                    ? 'Cập nhật sản phẩm thành công'
                    : 'Tạo sản phẩm thành công'),
                backgroundColor: AppColors.success,
              ));
              context.pop();
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ));
            } else if (state.currentStep == 1 && _isEdit) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã lưu thông tin cơ bản'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 1),
              ));
            }
          },
        ),
      ],
      child: BlocBuilder<AdminProductFormCubit, AdminProductFormState>(
        builder: (context, state) {
          final cubit = context.read<AdminProductFormCubit>();
          final needsConfirm =
              state.createdProductId != null && !state.isSuccess;

          return PopScope(
            canPop: !needsConfirm,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              final confirmed = await _showAbandonDialog(context);
              if (confirmed == true && context.mounted) {
                await cubit.deleteCreatedProduct();
                if (!context.mounted) return;
                if (cubit.state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Không thể xóa sản phẩm. Vui lòng xóa thủ công từ danh sách.'),
                    backgroundColor: AppColors.warning,
                    duration: Duration(seconds: 4),
                  ));
                }
                context.pop();
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text(_isEdit ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
              ),
              body: Column(
                children: [
                  _StepIndicator(currentStep: state.currentStep),
                  const Divider(height: 1),
                  Expanded(child: _buildBody(context, state, cubit)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminProductFormState state,
      AdminProductFormCubit cubit) {
    if (state.dropdownStatus == DropdownStatus.loading ||
        (state.isLoadingDetail && state.dropdownStatus != DropdownStatus.error)) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    if (state.dropdownStatus == DropdownStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                state.dropdownErrorMessage ?? 'Không thể tải danh sách.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: cubit.retryDropdowns,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return IndexedStack(
      index: state.currentStep,
      children: [
        // key forces recreation when editingId resolves so initialValue: picks up edit data.
        _Step1BasicInfoForm(
          key: ValueKey(state.editingId != null ? 'edit_${state.editingId}' : 'create'),
          state: state,
          cubit: cubit,
        ),
        _Step2VariantsForm(formState: state, formCubit: cubit),
        _Step3ImagesForm(formState: state, formCubit: cubit),
      ],
    );
  }

  Future<bool?> _showAbandonDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rời khỏi form?'),
        content: const Text(
          'Sản phẩm đã được tạo nhưng chưa hoàn tất.\nXóa sản phẩm này và thoát?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tiếp tục chỉnh sửa'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa & thoát'),
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = ['Thông tin', 'Biến thể', 'Hình ảnh'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      child: Row(
        children: List.generate(3, (i) {
          final isDone = i < currentStep;
          final isActive = i == currentStep;
          final color = (isDone || isActive) ? AppColors.primary : AppColors.textHint;

          return Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: (isDone || isActive) ? AppColors.primary : Colors.transparent,
                        border: Border.all(color: color, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? Colors.white : AppColors.textHint,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: isDone ? AppColors.primary : AppColors.divider,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

int? _resolvedProductId(AdminProductFormState state) =>
    state.createdProductId ?? state.editingId;

// ── Step 1: Basic Info Form ───────────────────────────────────────────────────

class _Step1BasicInfoForm extends StatefulWidget {
  final AdminProductFormState state;
  final AdminProductFormCubit cubit;

  const _Step1BasicInfoForm({super.key, required this.state, required this.cubit});

  @override
  State<_Step1BasicInfoForm> createState() => _Step1BasicInfoFormState();
}

class _Step1BasicInfoFormState extends State<_Step1BasicInfoForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  // Cached flattened category list — recomputed only when categories change.
  late List<({int id, String label})> _flatCategories;

  List<({int id, String label})> _flattenCategories(
      List<CategoryTreeNode> nodes, [int depth = 0]) {
    final result = <({int id, String label})>[];
    for (final node in nodes) {
      final prefix = depth > 0 ? '${'—' * depth} ' : '';
      result.add((id: node.id, label: '$prefix${node.name}'));
      result.addAll(_flattenCategories(node.children, depth + 1));
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.name);
    _descController = TextEditingController(text: widget.state.description);
    _flatCategories = _flattenCategories(widget.state.categories);
  }

  @override
  void didUpdateWidget(_Step1BasicInfoForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.categories != oldWidget.state.categories) {
      _flatCategories = _flattenCategories(widget.state.categories);
    }
    // Sync controllers when edit-mode data loads (cubit state diverges from controller).
    // copyWith preserves cursor position; the condition prevents spurious syncs during typing.
    if (_nameController.text != widget.state.name) {
      _nameController.value =
          _nameController.value.copyWith(text: widget.state.name);
    }
    if (_descController.text != widget.state.description) {
      _descController.value =
          _descController.value.copyWith(text: widget.state.description);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = widget.cubit;
    final flatCategories = _flatCategories;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm *',
                border: OutlineInputBorder(),
              ),
              onChanged: cubit.nameChanged,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên sản phẩm' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: cubit.descriptionChanged,
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<int>(
              initialValue: (state.categoryId != null &&
                      flatCategories.any((c) => c.id == state.categoryId))
                  ? state.categoryId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Danh mục *',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: flatCategories
                  .map((c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.label, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) cubit.categoryChanged(v);
              },
              validator: (v) => v == null ? 'Vui lòng chọn danh mục' : null,
            ),
            const SizedBox(height: 16),

            // Brand dropdown
            DropdownButtonFormField<int>(
              initialValue: (state.brandId != null &&
                      state.brands.any((b) => b.id == state.brandId))
                  ? state.brandId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Thương hiệu *',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: state.brands
                  .map((b) => DropdownMenuItem<int>(
                        value: b.id!,
                        child: Text(b.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) cubit.brandChanged(v);
              },
              validator: (v) => v == null ? 'Vui lòng chọn thương hiệu' : null,
            ),
            const SizedBox(height: 16),

            // Gender dropdown
            DropdownButtonFormField<Gender>(
              initialValue: state.gender,
              decoration: const InputDecoration(
                labelText: 'Giới tính *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: Gender.male, child: Text('Nam')),
                DropdownMenuItem(value: Gender.female, child: Text('Nữ')),
                DropdownMenuItem(value: Gender.unisex, child: Text('Unisex')),
              ],
              onChanged: (g) {
                if (g != null) cubit.genderChanged(g);
              },
              validator: (v) => v == null ? 'Vui lòng chọn giới tính' : null,
            ),
            const SizedBox(height: 16),

            // Status dropdown
            DropdownButtonFormField<ProductStatus>(
              initialValue: state.status,
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
              ),
              items: ProductStatus.values
                  .where((s) => s != ProductStatus.deleted)
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s == ProductStatus.active ? 'Đang bán' : 'Tạm ẩn'),
                      ))
                  .toList(),
              onChanged: (s) {
                if (s != null) cubit.statusChanged(s);
              },
            ),
            const SizedBox(height: 8),

            // Featured toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Nổi bật'),
              subtitle: const Text('Hiển thị trên trang chủ'),
              value: state.isFeatured,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => cubit.featuredToggled(),
            ),
            const SizedBox(height: 24),

            // Next button
            ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        cubit.submitStep1();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Tiếp theo', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Variants Form ─────────────────────────────────────────────────────

class _Step2VariantsForm extends StatefulWidget {
  final AdminProductFormState formState;
  final AdminProductFormCubit formCubit;

  const _Step2VariantsForm({required this.formState, required this.formCubit});

  @override
  State<_Step2VariantsForm> createState() => _Step2VariantsFormState();
}

class _Step2VariantsFormState extends State<_Step2VariantsForm> {
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
    final productId = _resolvedProductId(widget.formState);

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
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (variants.isEmpty && !_showAddForm)
                            _buildEmptyPlaceholder(productId),
                          ...variants.map(
                              (v) => _buildVariantRow(context, variantCubit, v)),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    setState(() => _showAddForm = true),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Thêm biến thể'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
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
                                          color: AppColors.warning, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            _buildNavButtons(context),
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
        subtitle: Text(
            '${variant.size} · ${variant.colorName} · ${_formatPrice(variant.salePrice ?? variant.originalPrice)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${variant.stockQuantity} cái',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
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

  Widget _buildAddForm(BuildContext context,
      AdminProductVariantCubit variantCubit,
      List<ProductColorEntity> colors,
      int? productId) {
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
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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
                                  border:
                                      Border.all(color: AppColors.divider),
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
                validator: (v) =>
                    v == null ? 'Vui lòng chọn màu sắc' : null,
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
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Bắt buộc'
                          : null,
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
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Bắt buộc'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Price row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
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
                  ),
                ],
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

              // Action buttons
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
                                setState(
                                    () => _isSubmittingVariant = true);
                                variantCubit.createVariant(
                                  productId,
                                  CreateVariantParams(
                                    sku: _skuController.text.trim(),
                                    size: _sizeController.text.trim(),
                                    colorId: _selectedColorId!,
                                    originalPrice: double.parse(
                                        _originalPriceController.text
                                            .trim()),
                                    salePrice: _salePriceController
                                            .text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : double.tryParse(
                                            _salePriceController.text
                                                .trim()),
                                    stockQuantity: int.parse(
                                        _stockController.text.trim()),
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

  Widget _buildNavButtons(BuildContext context) {
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

// ── Step 3: Images Form ───────────────────────────────────────────────────────

class _Step3ImagesForm extends StatefulWidget {
  final AdminProductFormState formState;
  final AdminProductFormCubit formCubit;

  const _Step3ImagesForm({required this.formState, required this.formCubit});

  @override
  State<_Step3ImagesForm> createState() => _Step3ImagesFormState();
}

class _Step3ImagesFormState extends State<_Step3ImagesForm> {
  static const _maxImages = 10;

  // Guards against double-tap launching two concurrent picker sessions.
  bool _isPicking = false;

  // Cached to prevent the grid disappearing when AdminProductImageFailure is emitted.
  List<ProductImageEntity> _lastKnownImages = [];

  late final AdminProductImageCubit _imageCubit;

  @override
  void initState() {
    super.initState();
    _imageCubit = context.read<AdminProductImageCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminProductImageCubit, AdminProductImageState>(
      listener: (context, state) {
        if (state is AdminProductImageSuccess) {
          _lastKnownImages = state.images;
        } else if (state is AdminProductImageFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ));
        }
      },
      builder: (context, imageState) {
        final images = _lastKnownImages;
        // Progress reflects the current file only — not overall batch progress.
        final uploadProgress = imageState is AdminProductImageUploading
            ? imageState.progress
            : null;
        final isUploading = uploadProgress != null;
        final productId = _resolvedProductId(widget.formState);

        return Column(
          children: [
            if (isUploading)
              LinearProgressIndicator(
                value: uploadProgress,
                backgroundColor: AppColors.divider,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hình ảnh sản phẩm (${images.length}/$_maxImages)',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (productId != null &&
                            images.length < _maxImages &&
                            !isUploading &&
                            !_isPicking)
                          _buildAddTile(productId, images.length),
                        ...images.map((img) =>
                            _buildImageTile(img, isUploading)),
                      ],
                    ),
                    if (productId == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
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
                                  'Hoàn tất thông tin cơ bản ở Bước 1 trước khi thêm ảnh.',
                                  style: TextStyle(
                                      color: AppColors.warning, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _buildNavButtons(isUploading),
          ],
        );
      },
    );
  }

  Widget _buildAddTile(int productId, int currentCount) {
    return GestureDetector(
      onTap: () => _pickAndUpload(productId, currentCount),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded,
                color: AppColors.primary, size: 28),
            SizedBox(height: 4),
            Text('Thêm ảnh',
                style: TextStyle(fontSize: 11, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(ProductImageEntity image, bool isUploading) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: image.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.broken_image, color: AppColors.textHint),
              ),
            ),
          ),
          if (image.isThumbnail)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Thumb',
                    style: TextStyle(color: Colors.white, fontSize: 9)),
              ),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              // Disable delete while uploading to prevent silent image restoration.
              onTap: isUploading ? null : () => _imageCubit.deleteImage(image.id),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isUploading
                      ? AppColors.textHint
                      : AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons(bool isUploading) {
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
              onPressed: isUploading ? null : widget.formCubit.goBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Quay lại'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: (widget.formState.isSubmitting || isUploading)
                  ? null
                  : widget.formCubit.completeForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: widget.formState.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Hoàn tất',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(int productId, int currentCount) async {
    setState(() => _isPicking = true);
    try {
      final files = await ImagePicker().pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (files.isEmpty) return;
      if (!mounted) return;

      final remaining = _maxImages - currentCount;
      final toUpload = files.take(remaining).toList();

      if (toUpload.length < files.length) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Chỉ tải lên $remaining ảnh còn lại (giới hạn $_maxImages ảnh)'),
          backgroundColor: AppColors.warning,
        ));
      }

      // Sequential upload: progress indicator reflects current file, not overall batch.
      for (final file in toUpload) {
        if (!mounted) break;
        await _imageCubit.addImage(productId, file);
        if (!mounted) break;
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }
}
