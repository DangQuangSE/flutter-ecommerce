import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:flutter_ecommerce/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:flutter_ecommerce/features/shop/domain/repositories/shop_repository.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_cubit.dart';

void setupShopModule(GetIt sl) {
  sl.registerLazySingleton<ShopRemoteDataSource>(
    () => ShopRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(sl<ShopRemoteDataSource>()),
  );
  sl.registerFactory<ShopCubit>(
    () => ShopCubit(sl<ShopRepository>()),
  );
}
