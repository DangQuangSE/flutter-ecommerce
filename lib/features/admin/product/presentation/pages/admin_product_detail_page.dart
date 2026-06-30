import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/detail/admin_product_detail_widgets.dart';

class AdminProductDetailPage extends StatelessWidget {
  final int productId;

  const AdminProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminProductDetailCubit, AdminProductDetailState>(
      listener: (context, state) {
        if (state is AdminProductDetailSuccess) {
          context
              .read<AdminProductVariantCubit>()
              .loadFromDetail(state.product.variants);
          context
              .read<AdminProductImageCubit>()
              .loadFromDetail(state.product.images);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AdminProductDetailCubit, AdminProductDetailState>(
            builder: (context, state) => Text(
              state is AdminProductDetailSuccess
                  ? state.product.name
                  : AppStrings.adminProductDetailTitle,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.pushNamed(
                AppRoutes.adminProductEdit,
                pathParameters: {'id': productId.toString()},
              ),
            ),
          ],
        ),
        body: BlocBuilder<AdminProductDetailCubit, AdminProductDetailState>(
          builder: (context, state) {
            if (state is AdminProductDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminProductDetailFailure) {
              return _DetailFailureView(
                message: state.message,
                onRetry: () =>
                    context.read<AdminProductDetailCubit>().refresh(productId),
              );
            }
            if (state is AdminProductDetailSuccess) {
              final product = state.product;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminProductInfoSection(product: product),
                    const SizedBox(height: AppSizes.paddingXl),
                    AdminProductDetailVariantsSection(
                      productId: productId,
                      productName: product.name,
                      brandName: product.brandName,
                    ),
                    const SizedBox(height: AppSizes.paddingXl),
                    AdminProductDetailImagesSection(productId: productId),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DetailFailureView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailFailureView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.adminProductDetailRetry),
            ),
          ],
        ),
      );
}
