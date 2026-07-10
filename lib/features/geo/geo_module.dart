import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/features/geo/data/datasources/directions_remote_datasource.dart';
import 'package:flutter_ecommerce/features/geo/data/datasources/places_remote_datasource.dart';
import 'package:flutter_ecommerce/features/geo/data/repositories/directions_repository_impl.dart';
import 'package:flutter_ecommerce/features/geo/data/repositories/places_repository_impl.dart';
import 'package:flutter_ecommerce/features/geo/data/services/device_location_service.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/directions_repository.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/store_location_picker_cubit.dart';

/// Registers the shared map/geo layer used by both the customer store screen
/// and the admin location picker. These call Google's web services directly
/// (đồ án) with a plain `Dio`, so no `DioClient` (backend) dependency here.
void setupGeoModule(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<DirectionsRemoteDataSource>(
    () => DirectionsRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<PlacesRemoteDataSource>(
    () => PlacesRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<DeviceLocationService>(
    () => const DeviceLocationService(),
  );

  // Repositories
  sl.registerLazySingleton<DirectionsRepository>(
    () => DirectionsRepositoryImpl(sl<DirectionsRemoteDataSource>()),
  );
  sl.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(sl<PlacesRemoteDataSource>()),
  );

  // Cubits
  sl.registerFactory<DirectionsCubit>(
    () => DirectionsCubit(
      sl<DirectionsRepository>(),
      sl<PlacesRepository>(),
      sl<DeviceLocationService>(),
    ),
  );
  sl.registerFactory<StoreLocationPickerCubit>(
    () => StoreLocationPickerCubit(sl<PlacesRepository>()),
  );
}
