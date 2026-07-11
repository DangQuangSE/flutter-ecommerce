import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/features/geo/data/datasources/places_remote_datasource.dart';
import 'package:flutter_ecommerce/features/geo/data/repositories/places_repository_impl.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/store_location_picker_cubit.dart';

/// Registers the shared map/geo layer used by both the customer store screen
/// and the admin location picker. These call Google's web services directly
/// (đồ án) with a plain `Dio`, so no `DioClient` (backend) dependency here.
void setupGeoModule(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<PlacesRemoteDataSource>(
    () => PlacesRemoteDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(sl<PlacesRemoteDataSource>()),
  );

  // Cubits
  sl.registerFactory<DirectionsCubit>(
    () => DirectionsCubit(sl<PlacesRepository>()),
  );
  sl.registerFactory<StoreLocationPickerCubit>(
    () => StoreLocationPickerCubit(sl<PlacesRepository>()),
  );
}
