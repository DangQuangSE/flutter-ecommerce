import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/order/data/datasources/order_remote_datasource.dart';
import 'package:flutter_ecommerce/features/order/data/datasources/order_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/order/data/repositories/order_repository_impl.dart';
import 'package:flutter_ecommerce/features/order/domain/repositories/order_repository.dart';
import 'package:flutter_ecommerce/features/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:flutter_ecommerce/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_bloc.dart';

void setupOrderModule(GetIt sl) {
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl<OrderRemoteDataSource>()),
  );
  sl.registerFactory<GetOrdersUseCase>(
    () => GetOrdersUseCase(sl<OrderRepository>()),
  );
  sl.registerFactory<GetOrderByIdUseCase>(
    () => GetOrderByIdUseCase(sl<OrderRepository>()),
  );
  sl.registerFactory<OrderBloc>(
    () => OrderBloc(
      getOrdersUseCase: sl<GetOrdersUseCase>(),
      getOrderByIdUseCase: sl<GetOrderByIdUseCase>(),
    ),
  );
}
