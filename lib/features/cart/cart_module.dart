import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:flutter_ecommerce/features/cart/data/datasources/cart_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:flutter_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';

void setupCartModule(GetIt sl) {
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartRemoteDataSource>()),
  );
  sl.registerLazySingleton<CartCubit>(
    () => CartCubit(sl<CartRepository>()),
  );
}
