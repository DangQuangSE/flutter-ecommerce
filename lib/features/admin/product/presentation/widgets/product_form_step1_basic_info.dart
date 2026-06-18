import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';

class ProductFormStep1BasicInfo extends StatefulWidget {
  final AdminProductFormState state;
  final AdminProductFormCubit cubit;

  const ProductFormStep1BasicInfo({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  State<ProductFormStep1BasicInfo> createState() =>
      _ProductFormStep1BasicInfoState();
}

class _ProductFormStep1BasicInfoState extends State<ProductFormStep1BasicInfo> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  late List<({int id, String label})> _flatCategories;

  List<({int id, String label})> _flattenCategories(
      List<CategoryTreeNode> nodes,
      [int depth = 0]) {
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
  void didUpdateWidget(ProductFormStep1BasicInfo oldWidget) {
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm *',
                border: OutlineInputBorder(),
              ),
              onChanged: cubit.nameChanged,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập tên sản phẩm'
                  : null,
            ),
            const SizedBox(height: 16),

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

            // Size group dropdown (optional)
            _SizeGroupDropdown(state: state, cubit: cubit),
            const SizedBox(height: 16),

            // Coupon dropdown (optional)
            _CouponDropdown(state: state, cubit: cubit),
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
                        child: Text(
                            s == ProductStatus.active ? 'Đang bán' : 'Tạm ẩn'),
                      ))
                  .toList(),
              onChanged: (s) {
                if (s != null) cubit.statusChanged(s);
              },
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Nổi bật'),
              subtitle: const Text('Hiển thị trên trang chủ'),
              value: state.isFeatured,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => cubit.featuredToggled(),
            ),
            const SizedBox(height: 24),

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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Tiếp theo',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeGroupDropdown extends StatelessWidget {
  final AdminProductFormState state;
  final AdminProductFormCubit cubit;

  const _SizeGroupDropdown({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final groups = state.sizeGroups;
    return DropdownButtonFormField<int?>(
      initialValue: (state.sizeGroupId != null &&
              groups.any((g) => g.id == state.sizeGroupId))
          ? state.sizeGroupId
          : null,
      decoration: const InputDecoration(
        labelText: 'Nhóm kích thước',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Không có nhóm kích thước'),
        ),
        ...groups.map(
          (g) => DropdownMenuItem<int?>(
            value: g.id,
            child: Text(g.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: cubit.sizeGroupChanged,
    );
  }
}

class _CouponDropdown extends StatelessWidget {
  final AdminProductFormState state;
  final AdminProductFormCubit cubit;

  const _CouponDropdown({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final coupons = state.coupons;
    return DropdownButtonFormField<int?>(
      initialValue:
          (state.couponId != null && coupons.any((c) => c.id == state.couponId))
              ? state.couponId
              : null,
      decoration: const InputDecoration(
        labelText: 'Mã giảm giá',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Không áp dụng mã giảm giá'),
        ),
        ...coupons.map(
          (c) => DropdownMenuItem<int?>(
            value: c.id,
            child: Text(c.code, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: cubit.couponChanged,
    );
  }
}
