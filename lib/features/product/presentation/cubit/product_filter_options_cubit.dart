import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_product_filter_options_usecase.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_state.dart';

class ProductFilterOptionsCubit extends Cubit<ProductFilterOptionsState> {
  final GetProductFilterOptionsUseCase _getFilterOptions;

  ProductFilterOptionsCubit(this._getFilterOptions)
      : super(const ProductFilterOptionsInitial());

  Future<void> loadOptions() async {
    emit(const ProductFilterOptionsLoading());

    final result = await _getFilterOptions();

    if (isClosed) return;

    var categories = const <CategoryTreeNode>[];
    var brands = const <BrandEntity>[];
    String? categoryError;
    String? brandError;

    switch (result.categories) {
      case Success(:final data):
        categories = data;
      case ResultFailure():
        categoryError = AppStrings.productFilterCategoryLoadError;
    }

    switch (result.brands) {
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
