import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/bulk_variant/bulk_variant_sheet.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/shared/variant_edit_dialog.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_state.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_state.dart';

class AdminProductInfoSection extends StatelessWidget {
  final AdminProductDetailEntity product;

  const AdminProductInfoSection({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSizes.paddingSm),
          Text(
            AppStrings.adminProductDetailLabel(
              AppStrings.adminProductDetailBrandLabel,
              product.brandName,
            ),
          ),
          Text(
            AppStrings.adminProductDetailLabel(
              AppStrings.adminProductDetailCategoryLabel,
              product.categoryName,
            ),
          ),
          Text(
            AppStrings.adminProductDetailLabel(
              AppStrings.adminProductDetailGenderLabel,
              product.gender.name,
            ),
          ),
          Text(
            AppStrings.adminProductDetailLabel(
              AppStrings.adminProductDetailStatusLabel,
              product.status.name.toUpperCase(),
            ),
          ),
          if (product.description != null) ...[
            const SizedBox(height: AppSizes.paddingSm),
            Text(product.description!),
          ],
        ],
      );
}

class AdminProductDetailVariantsSection extends StatelessWidget {
  final int productId;
  final String productName;
  final String brandName;

  const AdminProductDetailVariantsSection({
    super.key,
    required this.productId,
    required this.productName,
    required this.brandName,
  });

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

  Future<void> _showBulkSheet(
    BuildContext context,
    List<SizeGroupEntity> sizeGroups,
    List<ProductColorEntity> colors,
  ) async {
    final variantCubit = context.read<AdminProductVariantCubit>();
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
          sizeGroups: sizeGroups,
          colors: colors,
          productName: productName,
          brandName: brandName,
        ),
      ),
    );
    if (drafts != null && drafts.isNotEmpty && context.mounted) {
      variantCubit.createVariantsBatch(productId, drafts);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.adminProductDetailVariantsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              BlocBuilder<SizeGroupCubit, SizeGroupState>(
                builder: (context, sizeGroupState) =>
                    BlocBuilder<ProductColorCubit, ProductColorState>(
                  builder: (context, colorState) {
                    final groups = sizeGroupState is SizeGroupSuccess
                        ? sizeGroupState.groups
                        : <SizeGroupEntity>[];
                    final colors = colorState is ProductColorLoaded
                        ? colorState.colors
                        : <ProductColorEntity>[];
                    return TextButton.icon(
                      onPressed: groups.isNotEmpty && colors.isNotEmpty
                          ? () => _showBulkSheet(context, groups, colors)
                          : null,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text(
                        AppStrings.adminProductVariantCreateBulk,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          BlocConsumer<AdminProductVariantCubit, AdminProductVariantState>(
            listener: (context, state) {
              if (state is AdminProductVariantFailure) {
                AppSnackBar.show(
                  context,
                  message: state.message,
                  type: AppSnackBarType.error,
                );
              }
            },
            builder: (context, state) {
              if (state is AdminProductVariantLoading) {
                return const AppLoadingView();
              }
              if (state is AdminProductVariantSuccess) {
                if (state.variants.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.paddingMd,
                    ),
                    child: Text(
                      AppStrings.adminProductVariantEmptyTitle,
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  );
                }
                final variantCubit = context.read<AdminProductVariantCubit>();
                return Column(
                  children: state.variants
                      .map(
                        (variant) => _DetailVariantTile(
                          variant: variant,
                          onEdit: () =>
                              _onEditVariant(context, variantCubit, variant),
                          onDelete: () =>
                              variantCubit.deleteVariant(variant.id),
                        ),
                      )
                      .toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      );
}

class AdminProductDetailImagesSection extends StatelessWidget {
  final int productId;

  const AdminProductDetailImagesSection({
    super.key,
    required this.productId,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) return;
    if (context.mounted) {
      context.read<AdminProductImageCubit>().addImage(productId, file);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.adminProductDetailImagesTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () => _pickImage(context),
                icon: const Icon(Icons.upload),
                label: const Text(AppStrings.adminProductDetailUploadImage),
              ),
            ],
          ),
          BlocConsumer<AdminProductImageCubit, AdminProductImageState>(
            listener: (context, state) {
              if (state is AdminProductImageFailure) {
                AppSnackBar.show(
                  context,
                  message: state.message,
                  type: AppSnackBarType.error,
                );
              }
            },
            builder: (context, state) {
              if (state is AdminProductImageUploading) {
                return Column(
                  children: [
                    const Text(AppStrings.adminProductDetailUploadingImage),
                    LinearProgressIndicator(value: state.progress),
                  ],
                );
              }
              if (state is AdminProductImageSuccess) {
                if (state.images.isEmpty) {
                  return const Text(AppStrings.adminProductDetailNoImages);
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSizes.paddingSm,
                    mainAxisSpacing: AppSizes.paddingSm,
                  ),
                  itemCount: state.images.length,
                  itemBuilder: (context, index) {
                    final image = state.images[index];
                    return _ProductImageTile(
                      imageUrl: image.imageUrl,
                      isThumbnail: image.isThumbnail,
                      onDelete: () => context
                          .read<AdminProductImageCubit>()
                          .deleteImage(image.id),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      );
}

class _DetailVariantTile extends StatelessWidget {
  final ProductVariantEntity variant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DetailVariantTile({
    required this.variant,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final salePrice = variant.salePrice;
    return ListTile(
      title: Text(
        AppStrings.adminProductDetailVariantTitle(
          variant.size,
          variant.colorName,
        ),
      ),
      subtitle: Text(
        AppStrings.adminProductDetailVariantSubtitle(
          sku: variant.sku,
          stock: variant.stockQuantity,
          price: _formatPrice(variant.originalPrice),
          salePrice: salePrice == null ? null : _formatPrice(salePrice),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ProductImageTile extends StatelessWidget {
  final String imageUrl;
  final bool isThumbnail;
  final VoidCallback onDelete;

  const _ProductImageTile({
    required this.imageUrl,
    required this.isThumbnail,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                color: Colors.black54,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          if (isThumbnail)
            const Positioned(
              bottom: 0,
              left: 0,
              child: Icon(Icons.star, color: Colors.amber, size: 18),
            ),
        ],
      );
}

String _formatPrice(double price) =>
    '${price.toStringAsFixed(0)}${AppStrings.adminProductVariantPriceSuffix}';
