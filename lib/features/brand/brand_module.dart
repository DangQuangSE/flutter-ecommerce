import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/brand/data/datasources/brand_remote_datasource.dart';
import 'package:flutter_ecommerce/features/brand/data/datasources/brand_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/brand/data/repositories/brand_repository_impl.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';
import 'package:flutter_ecommerce/features/brand/presentation/cubit/brand_cubit.dart';

void setupBrandModule(GetIt sl) {
  sl.registerLazySingleton<BrandRemoteDataSource>(
    () => BrandRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<BrandRepository>(
    () => BrandRepositoryImpl(sl<BrandRemoteDataSource>()),
  );
  sl.registerFactory<BrandCubit>(
    () => BrandCubit(sl<BrandRepository>()),
  );
}
