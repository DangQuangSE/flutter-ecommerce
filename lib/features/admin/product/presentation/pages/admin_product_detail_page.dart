import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';

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
                    _VariantsSection(productId: productId),

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
  const _VariantsSection({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Biến thể',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () {
                // TODO: show add variant dialog
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm'),
            ),
          ],
        ),
        BlocConsumer<AdminProductVariantCubit, AdminProductVariantState>(
          listener: (context, state) {
            if (state is AdminProductVariantFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is AdminProductVariantLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminProductVariantSuccess) {
              if (state.variants.isEmpty) {
                return const Text('Chưa có biến thể nào');
              }
              return Column(
                children: state.variants.map((v) {
                  return ListTile(
                    title: Text('${v.size} — ${v.colorName}'),
                    subtitle: Text(
                        'SKU: ${v.sku} • Tồn: ${v.stockQuantity} • ${v.originalPrice.toStringAsFixed(0)}đ'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => context
                          .read<AdminProductVariantCubit>()
                          .deleteVariant(v.id),
                    ),
                  );
                }).toList(),
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
                    backgroundColor: Colors.red),
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
