import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_error_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/form/basic_info/product_form_step1_basic_info.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/form/images/product_form_step3_images.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/form/product_form_step_indicator.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/form/variants/product_form_step2_variants.dart';

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
                context.read<AdminProductFormCubit>().loadForEdit(
                      state.product,
                    );
                context.read<AdminProductVariantCubit>().loadFromDetail(
                      state.product.variants,
                    );
                context.read<AdminProductImageCubit>().loadFromDetail(
                      state.product.images,
                    );
              } else if (state is AdminProductDetailFailure) {
                _showSnack(
                  context,
                  state.message,
                  type: AppSnackBarType.error,
                );
                context.pop();
              }
            },
          ),
        BlocListener<AdminProductFormCubit, AdminProductFormState>(
          listenWhen: (prev, curr) =>
              prev.isSuccess != curr.isSuccess ||
              prev.errorMessage != curr.errorMessage ||
              (_isEdit &&
                  prev.currentStep != curr.currentStep &&
                  curr.currentStep == 1),
          listener: (context, state) {
            if (state.isSuccess && state.currentStep == 2) {
              _showSnack(
                context,
                _isEdit
                    ? AppStrings.adminProductUpdated
                    : AppStrings.adminProductCreated,
                type: AppSnackBarType.success,
              );
              context.pop();
            } else if (state.errorMessage != null) {
              _showSnack(
                context,
                state.errorMessage!,
                type: AppSnackBarType.error,
              );
            } else if (state.currentStep == 1 && _isEdit) {
              _showSnack(
                context,
                AppStrings.adminProductBasicInfoSaved,
                type: AppSnackBarType.success,
                duration: const Duration(seconds: 1),
              );
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
              if (confirmed && context.mounted) {
                await cubit.deleteCreatedProduct();
                if (!context.mounted) return;
                if (cubit.state.errorMessage != null) {
                  _showSnack(
                    context,
                    AppStrings.adminProductManualDeleteWarning,
                    type: AppSnackBarType.warning,
                    duration: const Duration(seconds: 4),
                  );
                }
                context.pop();
              }
            },
            child: Scaffold(
              
              appBar: AppBar(
                title: Text(
                  _isEdit
                      ? AppStrings.adminProductEditTitle
                      : AppStrings.adminProductCreateTitle,
                ),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
              ),
              body: Column(
                children: [
                  ProductFormStepIndicator(currentStep: state.currentStep),
                  const Divider(height: 1),
                  Expanded(child: _buildBody(state, cubit)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    AdminProductFormState state,
    AdminProductFormCubit cubit,
  ) {
    if (state.dropdownStatus == DropdownStatus.loading ||
        (state.isLoadingDetail &&
            state.dropdownStatus != DropdownStatus.error)) {
      return const AppLoadingView();
    }
    if (state.dropdownStatus == DropdownStatus.error) {
      return AppErrorView(
        title: AppStrings.adminProductDropdownLoadError,
        message: state.dropdownErrorMessage ??
            AppStrings.adminProductDropdownLoadError,
        onRetry: cubit.retryDropdowns,
      );
    }

    return IndexedStack(
      index: state.currentStep,
      children: [
        ProductFormStep1BasicInfo(
          key: ValueKey(
            state.editingId != null ? 'edit_${state.editingId}' : 'create',
          ),
          state: state,
          cubit: cubit,
        ),
        ProductFormStep2Variants(formState: state, formCubit: cubit),
        ProductFormStep3Images(formState: state, formCubit: cubit),
      ],
    );
  }

  Future<bool> _showAbandonDialog(BuildContext context) {
    return AppConfirmDialog.show(
      context,
      title: AppStrings.adminProductAbandonTitle,
      message: AppStrings.adminProductAbandonMessage,
      cancelLabel: AppStrings.adminProductContinueEditing,
      confirmLabel: AppStrings.adminProductDeleteAndExit,
    );
  }

  void _showSnack(
    BuildContext context,
    String message, {
    required AppSnackBarType type,
    Duration duration = const Duration(seconds: 2),
  }) {
    AppSnackBar.show(
      context,
      message: message,
      type: type,
      duration: duration,
    );
  }
}
