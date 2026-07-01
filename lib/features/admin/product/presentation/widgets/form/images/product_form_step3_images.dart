import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/form/images/product_image_form_widgets.dart';
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
  static const _maxImageDimension = 1920.0;
  static const _imageQuality = 85;

  // Guards against double-tap launching two concurrent picker sessions.
  bool _isPicking = false;

  // Cached to prevent the grid disappearing when AdminProductImageFailure is emitted.
  List<ProductImageEntity> _lastKnownImages = [];

  late AdminProductImageCubit _imageCubit;
  bool _didResolveImageCubit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didResolveImageCubit) return;
    _imageCubit = context.read<AdminProductImageCubit>();
    _didResolveImageCubit = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminProductImageCubit, AdminProductImageState>(
      listener: (context, state) {
        if (state is AdminProductImageSuccess) {
          _lastKnownImages = state.images;
        } else if (state is AdminProductImageFailure) {
          AppSnackBar.show(
            context,
            message: state.message,
            type: AppSnackBarType.error,
          );
        }
      },
      builder: (context, imageState) {
        final images = _lastKnownImages;
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
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductImagesHeader(
                      count: images.length,
                      maxImages: _maxImages,
                    ),
                    const SizedBox(height: AppSizes.paddingSm + 4),
                    Wrap(
                      spacing: AppSizes.paddingSm,
                      runSpacing: AppSizes.paddingSm,
                      children: [
                        if (productId != null &&
                            images.length < _maxImages &&
                            !isUploading &&
                            !_isPicking)
                          ProductAddImageTile(
                            onTap: () =>
                                _pickAndUpload(productId, images.length),
                          ),
                        ...images.map(
                          (image) => ProductImageTile(
                            image: image,
                            isUploading: isUploading,
                            onDelete: () => _imageCubit.deleteImage(image.id),
                          ),
                        ),
                      ],
                    ),
                    if (productId == null) const ProductImageBasicInfoWarning(),
                  ],
                ),
              ),
            ),
            ProductImageStepNavigation(
              isUploading: isUploading,
              isSubmitting: widget.formState.isSubmitting,
              onBack: widget.formCubit.goBack,
              onComplete: widget.formCubit.completeForm,
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUpload(int productId, int currentCount) async {
    setState(() => _isPicking = true);
    try {
      final files = await ImagePicker().pickMultiImage(
        maxWidth: _maxImageDimension,
        maxHeight: _maxImageDimension,
        imageQuality: _imageQuality,
      );
      if (files.isEmpty) return;
      if (!mounted) return;

      final remaining = _maxImages - currentCount;
      final toUpload = files.take(remaining).toList();

      if (toUpload.length < files.length) {
        AppSnackBar.show(
          context,
          message: AppStrings.adminProductImagesUploadLimit(
            remaining,
            _maxImages,
          ),
          type: AppSnackBarType.warning,
        );
      }

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
