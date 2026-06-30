import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_state.dart';

class ProductFilterOptionsCubit extends Cubit<ProductFilterOptionsState> {
  final CategoryRepository _categoryRepository;
  final BrandRepository _brandRepository;

  ProductFilterOptionsCubit({
    required CategoryRepository categoryRepository,
    required BrandRepository brandRepository,
  })  : _categoryRepository = categoryRepository,
        _brandRepository = brandRepository,
        super(const ProductFilterOptionsInitial());

  Future<void> loadOptions() async {
    emit(const ProductFilterOptionsLoading());

    final categoryResult = await _categoryRepository.getTree();
    final brandResult = await _brandRepository.getBrands(size: 200);

    if (isClosed) return;

    var categories = const <CategoryTreeNode>[];
    var brands = const <BrandEntity>[];
    String? categoryError;
    String? brandError;

    switch (categoryResult) {
      case Success(:final data):
        categories = data;
      case ResultFailure():
        categoryError = AppStrings.productFilterCategoryLoadError;
    }

    switch (brandResult) {
      case Success(:final data):
        brands = data.where((brand) => brand.isActive).toList();
      case ResultFailure():
        brandError = AppStrings.productFilterBrandLoadError;
    }

    emit(ProductFilterOptionsLoaded(
      categories: categories,
      brands: brands,
      categoryError: categoryError,
      brandError: brandError,
    ));
  }
}
