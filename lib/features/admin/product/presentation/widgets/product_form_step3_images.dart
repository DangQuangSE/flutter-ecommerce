import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormStep3Images extends StatefulWidget {
  final AdminProductFormState formState;
  final AdminProductFormCubit formCubit;

  const ProductFormStep3Images({
    super.key,
    required this.formState,
    required this.formCubit,
  });

  @override
  State<ProductFormStep3Images> createState() => _ProductFormStep3ImagesState();
}

class _ProductFormStep3ImagesState extends State<ProductFormStep3Images> {
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
        final productId = widget.formState.resolvedProductId;

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
                        ...images
                            .map((img) => _buildImageTile(img, isUploading)),
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
            Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 28),
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
              onTap:
                  isUploading ? null : () => _imageCubit.deleteImage(image.id),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isUploading ? AppColors.textHint : AppColors.error,
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
