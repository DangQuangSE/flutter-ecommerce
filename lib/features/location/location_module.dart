import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/features/location/data/datasources/location_remote_datasource.dart';
import 'package:flutter_ecommerce/features/location/data/datasources/location_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/location/data/repositories/location_repository_impl.dart';
import 'package:flutter_ecommerce/features/location/domain/repositories/location_repository.dart';
import 'package:flutter_ecommerce/features/location/presentation/cubit/location_cubit.dart';

void setupLocationModule(GetIt sl) {
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl<LocationRemoteDataSource>()),
  );
  sl.registerFactory<LocationCubit>(
    () => LocationCubit(sl<LocationRepository>()),
  );
}
