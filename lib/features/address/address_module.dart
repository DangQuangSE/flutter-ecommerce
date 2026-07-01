import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/address/data/datasources/address_remote_datasource.dart';
import 'package:flutter_ecommerce/features/address/data/datasources/address_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/address/data/repositories/address_repository_impl.dart';
import 'package:flutter_ecommerce/features/address/domain/repositories/address_repository.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';

void setupAddressModule(GetIt sl) {
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(sl<AddressRemoteDataSource>()),
  );
  sl.registerLazySingleton<AddressCubit>(
    () => AddressCubit(sl<AddressRepository>()),
  );
}
