import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/printing_color_remote_datasource.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/printing_color_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/product_color_remote_datasource.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/product_color_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/color/data/repositories/printing_color_repository_impl.dart';
import 'package:flutter_ecommerce/features/color/data/repositories/product_color_repository_impl.dart';
import 'package:flutter_ecommerce/features/color/domain/repositories/printing_color_repository.dart';
import 'package:flutter_ecommerce/features/color/domain/repositories/product_color_repository.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/printing_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';

void setupColorModule(GetIt sl) {
  sl.registerLazySingleton<ProductColorRemoteDataSource>(
    () => ProductColorRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ProductColorRepository>(
    () => ProductColorRepositoryImpl(sl<ProductColorRemoteDataSource>()),
  );
  sl.registerFactory<ProductColorCubit>(
    () => ProductColorCubit(sl<ProductColorRepository>()),
  );

  sl.registerLazySingleton<PrintingColorRemoteDataSource>(
    () => PrintingColorRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<PrintingColorRepository>(
    () => PrintingColorRepositoryImpl(sl<PrintingColorRemoteDataSource>()),
  );
  sl.registerFactory<PrintingColorCubit>(
    () => PrintingColorCubit(sl<PrintingColorRepository>()),
  );
}
