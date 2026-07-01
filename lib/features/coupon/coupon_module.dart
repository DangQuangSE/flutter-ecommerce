import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/coupon/data/datasources/coupon_remote_datasource.dart';
import 'package:flutter_ecommerce/features/coupon/data/repositories/coupon_repository_impl.dart';
import 'package:flutter_ecommerce/features/coupon/domain/repositories/coupon_repository.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';

void setupCouponModule(GetIt sl) {
  sl.registerLazySingleton<CouponRemoteDataSource>(
    () => CouponRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<CouponRepository>(
    () => CouponRepositoryImpl(sl<CouponRemoteDataSource>()),
  );
  sl.registerFactory<CouponCubit>(
    () => CouponCubit(sl<CouponRepository>()),
  );
}
