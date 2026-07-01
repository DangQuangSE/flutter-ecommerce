import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/storage/local_storage.dart';
import 'package:flutter_ecommerce/features/category/data/datasources/category_remote_datasource.dart';
import 'package:flutter_ecommerce/features/category/data/network/category_api_client.dart';
import 'package:flutter_ecommerce/features/category/data/repositories/category_repository_impl.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';

void setupCategoryModule(GetIt sl) {
  sl.registerLazySingleton<CategoryApiClient>(
    () => CategoryApiClient(sl<LocalStorage>()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl<CategoryApiClient>()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
  );
  sl.registerFactory<CategoryCubit>(
    () => CategoryCubit(sl<CategoryRepository>()),
  );
}
