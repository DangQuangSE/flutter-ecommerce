import 'package:flutter_ecommerce/features/color/data/models/product_color_model.dart';

abstract interface class ProductColorRemoteDataSource {
  Future<List<ProductColorModel>> getColors();
  Future<ProductColorModel> createColor(ProductColorModel color);
  Future<ProductColorModel> updateColor(int id, ProductColorModel color);
  Future<void> deleteColor(int id);
}
