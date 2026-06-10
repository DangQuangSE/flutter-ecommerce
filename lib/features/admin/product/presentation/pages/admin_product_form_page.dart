import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';

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
                context.read<AdminProductFormCubit>().loadForEdit(state.product);
              }
            },
          ),
        BlocListener<AdminProductFormCubit, AdminProductFormState>(
          listenWhen: (prev, curr) =>
              prev.isSuccess != curr.isSuccess ||
              prev.errorMessage != curr.errorMessage ||
              (_isEdit && prev.currentStep != curr.currentStep && curr.currentStep == 1),
          listener: (context, state) {
            if (state.isSuccess) {
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
                if (context.mounted) context.pop();
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
        state.isLoadingDetail) {
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
        _Step1BasicInfoForm(state: state, cubit: cubit),
        const Center(child: Text('Biến thể — Phase 3')), // replaced in Phase 3
        const Center(child: Text('Hình ảnh — Phase 4')), // replaced in Phase 4
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

// ── Step 1: Basic Info Form ───────────────────────────────────────────────────

class _Step1BasicInfoForm extends StatefulWidget {
  final AdminProductFormState state;
  final AdminProductFormCubit cubit;

  const _Step1BasicInfoForm({required this.state, required this.cubit});

  @override
  State<_Step1BasicInfoForm> createState() => _Step1BasicInfoFormState();
}

class _Step1BasicInfoFormState extends State<_Step1BasicInfoForm> {
  final _formKey = GlobalKey<FormState>();

  // Cached flattened category list — recomputed only when categories change.
  // TODO(Phase5): replace TextFormField(initialValue:) with TextEditingController
  // so that loadForEdit() pre-populates text fields in edit mode.
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
    _flatCategories = _flattenCategories(widget.state.categories);
  }

  @override
  void didUpdateWidget(_Step1BasicInfoForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.categories != oldWidget.state.categories) {
      _flatCategories = _flattenCategories(widget.state.categories);
    }
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
              initialValue: state.name,
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
              initialValue: state.description,
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
