import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/product/data/repositories/product_repository_impl.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/add_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_product_catalog_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_product_filter_options_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/update_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_cubit.dart';

void setupProductModule(GetIt sl) {
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<GetProductCatalogUseCase>(
    () => GetProductCatalogUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<GetProductFilterOptionsUseCase>(
    () => GetProductFilterOptionsUseCase(
      categoryRepository: sl<CategoryRepository>(),
      brandRepository: sl<BrandRepository>(),
    ),
  );
  sl.registerLazySingleton<AddProductUseCase>(
    () => AddProductUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<DeleteProductUseCase>(
    () => DeleteProductUseCase(sl<ProductRepository>()),
  );
  sl.registerFactory<ProductBloc>(
    () => ProductBloc(
      getProductsUseCase: sl<GetProductsUseCase>(),
      productRepository: sl<ProductRepository>(),
    ),
  );
  sl.registerFactory<ProductCatalogBloc>(
    () => ProductCatalogBloc(sl<GetProductCatalogUseCase>()),
  );
  sl.registerFactory<ProductFilterOptionsCubit>(
    () => ProductFilterOptionsCubit(sl<GetProductFilterOptionsUseCase>()),
  );
}
