import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/product_form_step_indicator.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/product_form_step1_basic_info.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/product_form_step2_variants.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/product_form_step3_images.dart';

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
                  ProductFormStepIndicator(currentStep: state.currentStep),
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
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
        ProductFormStep1BasicInfo(
          key: ValueKey(
              state.editingId != null ? 'edit_${state.editingId}' : 'create'),
          state: state,
          cubit: cubit,
        ),
        ProductFormStep2Variants(formState: state, formCubit: cubit),
        ProductFormStep3Images(formState: state, formCubit: cubit),
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
