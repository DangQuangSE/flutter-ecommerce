import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';

abstract interface class BrandRepository {
  Future<Result<List<BrandEntity>>> getBrands({
    int page = 0,
    int size = 100,
    String? search,
  });

  Future<Result<BrandEntity>> createBrand(BrandEntity brand);

  Future<Result<BrandEntity>> updateBrand(int id, BrandEntity brand);

  Future<Result<void>> deleteBrand(int id);

  Future<Result<void>> updateBrandStatus(int id, bool isActive);
}
