import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/image_file_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/add_product_image_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_product_image_usecase.dart';

part 'admin_product_image_state.dart';

class AdminProductImageCubit extends Cubit<AdminProductImageState> {
  final AddProductImageUseCase _addImage;
  final DeleteProductImageUseCase _deleteImage;

  AdminProductImageCubit(this._addImage, this._deleteImage)
      : super(AdminProductImageInitial());

  void loadFromDetail(List<ProductImageEntity> images) {
    emit(AdminProductImageSuccess(images));
  }

  Future<void> addImage(
    int productId,
    XFile file, {
    bool isThumbnail = false,
    int sortOrder = 0,
  }) async {
    final current = _currentImages;
    emit(AdminProductImageUploading(0.0));

    final params = ImageFileParams(path: file.path, name: file.name);
    final result = await _addImage(
      productId,
      params,
      isThumbnail: isThumbnail,
      sortOrder: sortOrder,
      onSendProgress: (sent, total) {
        if (!isClosed) {
          emit(AdminProductImageUploading(total > 0 ? sent / total : 0.0));
        }
      },
    );

    switch (result) {
      case Success(:final data):
        emit(AdminProductImageSuccess([...current, data]));
      case ResultFailure(:final failure):
        emit(AdminProductImageSuccess(current));
        emit(AdminProductImageFailure(failure.message));
    }
  }

  Future<void> deleteImage(int imageId) async {
    final current = _currentImages;
    final result = await _deleteImage(imageId);
    switch (result) {
      case Success():
        emit(AdminProductImageSuccess(
            current.where((i) => i.id != imageId).toList()));
      case ResultFailure(:final failure):
        emit(AdminProductImageSuccess(current));
        emit(AdminProductImageFailure(failure.message));
    }
  }

  List<ProductImageEntity> get _currentImages {
    final s = state;
    return s is AdminProductImageSuccess ? s.images : [];
  }
}
