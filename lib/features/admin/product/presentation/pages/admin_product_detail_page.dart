import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/bulk_variant_sheet.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/variant_edit_dialog.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_state.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_state.dart';

class AdminProductDetailPage extends StatelessWidget {
  final int productId;
  const AdminProductDetailPage({super.key, required this.productId});

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
            builder: (context, state) {
              return Text(state is AdminProductDetailSuccess
                  ? state.product.name
                  : 'Chi tiết sản phẩm');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('/admin/products/$productId/edit'),
            ),
          ],
        ),
        body: BlocBuilder<AdminProductDetailCubit, AdminProductDetailState>(
          builder: (context, state) {
            if (state is AdminProductDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminProductDetailFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AdminProductDetailCubit>()
                          .refresh(productId),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            if (state is AdminProductDetailSuccess) {
              final product = state.product;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product info
                    Text(product.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Thương hiệu: ${product.brandName}'),
                    Text('Danh mục: ${product.categoryName}'),
                    Text('Giới tính: ${product.gender.name}'),
                    Text('Trạng thái: ${product.status.name.toUpperCase()}'),
                    if (product.description != null) ...[
                      const SizedBox(height: 8),
                      Text(product.description!),
                    ],

                    const SizedBox(height: 24),

                    // Variants section
                    _VariantsSection(
                      productId: productId,
                      productName: product.name,
                      brandName: product.brandName,
                    ),

                    const SizedBox(height: 24),

                    // Images section
                    _ImagesSection(productId: productId),
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

class _VariantsSection extends StatelessWidget {
  final int productId;
  final String productName;
  final String brandName;
  const _VariantsSection({
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

  Future<void> _showBulkSheet(BuildContext context,
      List<SizeGroupEntity> sizeGroups, List<ProductColorEntity> colors) async {
    final variantCubit = context.read<AdminProductVariantCubit>();
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Biến thể', style: Theme.of(context).textTheme.titleMedium),
            BlocBuilder<SizeGroupCubit, SizeGroupState>(
              builder: (context, sgState) =>
                  BlocBuilder<ProductColorCubit, ProductColorState>(
                builder: (context, colorState) {
                  final groups = sgState is SizeGroupSuccess
                      ? sgState.groups
                      : <SizeGroupEntity>[];
                  final colors = colorState is ProductColorLoaded
                      ? colorState.colors
                      : <ProductColorEntity>[];
                  return TextButton.icon(
                    onPressed: groups.isNotEmpty && colors.isNotEmpty
                        ? () => _showBulkSheet(context, groups, colors)
                        : null,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text('Tạo hàng loạt'),
                  );
                },
              ),
            ),
          ],
        ),
        BlocConsumer<AdminProductVariantCubit, AdminProductVariantState>(
          listener: (context, state) {
            if (state is AdminProductVariantFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ));
            }
          },
          builder: (context, state) {
            if (state is AdminProductVariantLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminProductVariantSuccess) {
              if (state.variants.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Chưa có biến thể nào',
                      style: TextStyle(color: AppColors.textHint)),
                );
              }
              final variantCubit = context.read<AdminProductVariantCubit>();
              return Column(
                children: state.variants.map((v) => ListTile(
                      title: Text('${v.size} — ${v.colorName}'),
                      subtitle: Text(
                          'SKU: ${v.sku} • Tồn: ${v.stockQuantity} • ${v.originalPrice.toStringAsFixed(0)}đ'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.primary),
                            onPressed: () =>
                                _onEditVariant(context, variantCubit, v),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error),
                            onPressed: () => variantCubit.deleteVariant(v.id),
                          ),
                        ],
                      ),
                    )).toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _ImagesSection extends StatelessWidget {
  final int productId;
  const _ImagesSection({required this.productId});

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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ảnh sản phẩm',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => _pickImage(context),
              icon: const Icon(Icons.upload),
              label: const Text('Tải ảnh'),
            ),
          ],
        ),
        BlocConsumer<AdminProductImageCubit, AdminProductImageState>(
          listener: (context, state) {
            if (state is AdminProductImageFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            if (state is AdminProductImageUploading) {
              return Column(
                children: [
                  const Text('Đang tải ảnh...'),
                  LinearProgressIndicator(value: state.progress),
                ],
              );
            }
            if (state is AdminProductImageSuccess) {
              if (state.images.isEmpty) {
                return const Text('Chưa có ảnh nào');
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.images.length,
                itemBuilder: (context, i) {
                  final img = state.images[i];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(img.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => context
                              .read<AdminProductImageCubit>()
                              .deleteImage(img.id),
                          child: Container(
                            color: Colors.black54,
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      if (img.isThumbnail)
                        const Positioned(
                          bottom: 0,
                          left: 0,
                          child: Icon(Icons.star,
                              color: Colors.amber, size: 18),
                        ),
                    ],
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
}
