import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_image_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_image_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_variant_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_variant_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/product/data/repositories/admin_product_repository_impl.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/add_product_image_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_variant_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_variants_batch_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_product_image_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_variant_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/get_admin_product_detail_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/get_admin_products_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/restore_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/update_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/update_variant_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/bloc/admin_product_list_bloc.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/get_size_groups_usecase.dart';

void setupAdminProductModule(GetIt sl) {
  sl.registerLazySingleton<AdminProductDatasource>(
    () => AdminProductDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminProductVariantDatasource>(
    () => AdminProductVariantDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminProductImageDatasource>(
    () => AdminProductImageDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminProductRepository>(
    () => AdminProductRepositoryImpl(
      sl<AdminProductDatasource>(),
      sl<AdminProductVariantDatasource>(),
      sl<AdminProductImageDatasource>(),
    ),
  );
  sl.registerLazySingleton<GetAdminProductsUseCase>(
    () => GetAdminProductsUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<GetAdminProductDetailUseCase>(
    () => GetAdminProductDetailUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<CreateProductUseCase>(
    () => CreateProductUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<UpdateAdminProductUseCase>(
    () => UpdateAdminProductUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<DeleteAdminProductUseCase>(
    () => DeleteAdminProductUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<RestoreAdminProductUseCase>(
    () => RestoreAdminProductUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<CreateVariantUseCase>(
    () => CreateVariantUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<CreateVariantsBatchUseCase>(
    () => CreateVariantsBatchUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<UpdateVariantUseCase>(
    () => UpdateVariantUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<DeleteVariantUseCase>(
    () => DeleteVariantUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<AddProductImageUseCase>(
    () => AddProductImageUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<DeleteProductImageUseCase>(
    () => DeleteProductImageUseCase(sl<AdminProductRepository>()),
  );
  sl.registerFactory<AdminProductListBloc>(
    () => AdminProductListBloc(
      sl<GetAdminProductsUseCase>(),
      sl<DeleteAdminProductUseCase>(),
      sl<RestoreAdminProductUseCase>(),
    ),
  );
  sl.registerFactory<AdminProductDetailCubit>(
    () => AdminProductDetailCubit(sl<GetAdminProductDetailUseCase>()),
  );
  sl.registerFactory<AdminProductFormCubit>(
    () => AdminProductFormCubit(
      sl<CreateProductUseCase>(),
      sl<UpdateAdminProductUseCase>(),
      sl<DeleteAdminProductUseCase>(),
      sl<CategoryRepository>(),
      sl<BrandRepository>(),
      sl<GetSizeGroupsUseCase>(),
    ),
  );
  sl.registerFactory<AdminProductVariantCubit>(
    () => AdminProductVariantCubit(
      sl<CreateVariantUseCase>(),
      sl<CreateVariantsBatchUseCase>(),
      sl<UpdateVariantUseCase>(),
      sl<DeleteVariantUseCase>(),
    ),
  );
  sl.registerFactory<AdminProductImageCubit>(
    () => AdminProductImageCubit(
      sl<AddProductImageUseCase>(),
      sl<DeleteProductImageUseCase>(),
    ),
  );
}
