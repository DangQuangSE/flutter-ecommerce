import 'package:flutter_ecommerce/features/brand/data/models/brand_model.dart';

abstract interface class BrandRemoteDataSource {
  Future<List<BrandModel>> getBrands(
      {int page = 0, int size = 100, String? search});
  Future<BrandModel> createBrand(BrandModel brand);
  Future<BrandModel> updateBrand(int id, BrandModel brand);
  Future<void> deleteBrand(int id);
  Future<void> updateBrandStatus(int id, bool isActive);
}
