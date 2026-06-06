import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';

abstract interface class ProductColorRepository {
  Future<Result<List<ProductColorEntity>>> getColors();
  Future<Result<ProductColorEntity>> createColor(ProductColorEntity color);
  Future<Result<ProductColorEntity>> updateColor(int id, ProductColorEntity color);
  Future<Result<void>> deleteColor(int id);
}
