import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';

class AdminProductFormPage extends StatelessWidget {
  final int? productId;
  const AdminProductFormPage({super.key, this.productId});

  bool get _isEdit => productId != null;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // When detail loads in edit mode → populate form
        if (_isEdit)
          BlocListener<AdminProductDetailCubit, AdminProductDetailState>(
            listener: (context, state) {
              if (state is AdminProductDetailSuccess) {
                context
                    .read<AdminProductFormCubit>()
                    .loadForEdit(state.product);
              }
            },
          ),
        // Submit result listener
        BlocListener<AdminProductFormCubit, AdminProductFormState>(
          listenWhen: (prev, curr) =>
              prev.isSuccess != curr.isSuccess ||
              prev.errorMessage != curr.errorMessage,
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEdit
                      ? 'Cập nhật sản phẩm thành công'
                      : 'Tạo sản phẩm thành công'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'),
        ),
        body: BlocBuilder<AdminProductFormCubit, AdminProductFormState>(
          builder: (context, state) {
            if (state.isLoadingDetail) {
              return const Center(child: CircularProgressIndicator());
            }
            final cubit = context.read<AdminProductFormCubit>();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    initialValue: state.name,
                    decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm *',
                        border: OutlineInputBorder()),
                    onChanged: cubit.nameChanged,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: state.description,
                    decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder()),
                    maxLines: 3,
                    onChanged: cubit.descriptionChanged,
                  ),
                  const SizedBox(height: 16),

                  // Gender dropdown
                  DropdownButtonFormField<Gender>(
                    value: state.gender,
                    decoration: const InputDecoration(
                        labelText: 'Giới tính *',
                        border: OutlineInputBorder()),
                    items: Gender.values
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g.name),
                            ))
                        .toList(),
                    onChanged: (g) {
                      if (g != null) cubit.genderChanged(g);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  DropdownButtonFormField<ProductStatus>(
                    value: state.status,
                    decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder()),
                    items: ProductStatus.values
                        .where((s) => s != ProductStatus.deleted)
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (s) {
                      if (s != null) cubit.statusChanged(s);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category ID field (placeholder — normally a picker)
                  TextFormField(
                    initialValue:
                        state.categoryId?.toString() ?? '',
                    decoration: const InputDecoration(
                        labelText: 'Category ID *',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final id = int.tryParse(v);
                      if (id != null) cubit.categoryChanged(id);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Brand ID field (placeholder — normally a picker)
                  TextFormField(
                    initialValue:
                        state.brandId?.toString() ?? '',
                    decoration: const InputDecoration(
                        labelText: 'Brand ID *',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final id = int.tryParse(v);
                      if (id != null) cubit.brandChanged(id);
                    },
                  ),
                  const SizedBox(height: 8),

                  SwitchListTile(
                    title: const Text('Nổi bật'),
                    value: state.isFeatured,
                    onChanged: (_) => cubit.featuredToggled(),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed:
                        state.isSubmitting ? null : cubit.submit,
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEdit ? 'Lưu thay đổi' : 'Tạo sản phẩm'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
