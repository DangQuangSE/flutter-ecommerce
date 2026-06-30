import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';

typedef ProductFilterOptionsResult = ({
  Result<List<CategoryTreeNode>> categories,
  Result<List<BrandEntity>> brands,
});

class GetProductFilterOptionsUseCase {
  final CategoryRepository _categoryRepository;
  final BrandRepository _brandRepository;

  GetProductFilterOptionsUseCase({
    required CategoryRepository categoryRepository,
    required BrandRepository brandRepository,
  })  : _categoryRepository = categoryRepository,
        _brandRepository = brandRepository;

  Future<ProductFilterOptionsResult> call() async {
    final categoryResult = await _categoryRepository.getTree();
    final brandResult = await _brandRepository.getBrands(size: 200);

    return (
      categories: categoryResult,
      brands: brandResult,
    );
  }
}
