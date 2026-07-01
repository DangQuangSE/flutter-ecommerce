import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:flutter_ecommerce/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_ecommerce/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_cubit.dart';

void setupProfileModule(GetIt sl) {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );
  sl.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(sl<ProfileRepository>()),
  );
}
