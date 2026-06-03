part of 'admin_product_image_cubit.dart';

sealed class AdminProductImageState {}

class AdminProductImageInitial extends AdminProductImageState {}

class AdminProductImageUploading extends AdminProductImageState {
  final double progress;
  AdminProductImageUploading(this.progress);
}

class AdminProductImageSuccess extends AdminProductImageState {
  final List<ProductImageEntity> images;
  AdminProductImageSuccess(this.images);
}

class AdminProductImageFailure extends AdminProductImageState {
  final String message;
  AdminProductImageFailure(this.message);
}
