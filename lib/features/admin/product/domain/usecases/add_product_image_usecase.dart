import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/image_file_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';

class AddProductImageUseCase {
  final AdminProductRepository _repository;

  AddProductImageUseCase(this._repository);

  Future<Result<ProductImageEntity>> call(
    int productId,
    ImageFileParams file, {
    bool isThumbnail = false,
    int sortOrder = 0,
    int? variantId,
    void Function(int, int)? onSendProgress,
  }) =>
      _repository.addImage(
        productId,
        file,
        isThumbnail: isThumbnail,
        sortOrder: sortOrder,
        variantId: variantId,
        onSendProgress: onSendProgress,
      );
}
