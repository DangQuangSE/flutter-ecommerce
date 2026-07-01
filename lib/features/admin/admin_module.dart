import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_order_remote_datasource.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_order_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/data/repositories/admin_order_repository_impl.dart';
import 'package:flutter_ecommerce/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_order_repository.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_repository.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_order_detail_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_orders_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_stats_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/update_admin_order_status_usecase.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/add_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/update_product_usecase.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_socket_client.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_notification_cubit.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_notifications_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/mark_all_admin_notifications_as_read_usecase.dart';

void setupAdminModule(GetIt sl) {
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAdminStatsUseCase>(
    () => GetAdminStatsUseCase(sl<AdminRepository>()),
  );
  sl.registerLazySingleton<AdminOrderRemoteDataSource>(
    () => AdminOrderRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminOrderRepository>(
    () => AdminOrderRepositoryImpl(sl<AdminOrderRemoteDataSource>()),
  );
  sl.registerFactory<GetAdminOrdersUseCase>(
    () => GetAdminOrdersUseCase(sl<AdminOrderRepository>()),
  );
  sl.registerFactory<GetAdminOrderDetailUseCase>(
    () => GetAdminOrderDetailUseCase(sl<AdminOrderRepository>()),
  );
  sl.registerFactory<UpdateAdminOrderStatusUseCase>(
    () => UpdateAdminOrderStatusUseCase(sl<AdminOrderRepository>()),
  );
  sl.registerFactory<AdminOrderCubit>(
    () => AdminOrderCubit(
      getAdminOrdersUseCase: sl<GetAdminOrdersUseCase>(),
      getAdminOrderDetailUseCase: sl<GetAdminOrderDetailUseCase>(),
      updateAdminOrderStatusUseCase: sl<UpdateAdminOrderStatusUseCase>(),
    ),
  );
  sl.registerFactory<AdminBloc>(
    () => AdminBloc(
      getAdminStatsUseCase: sl<GetAdminStatsUseCase>(),
      getAdminOrdersUseCase: sl<GetAdminOrdersUseCase>(),
      getProductsUseCase: sl<GetProductsUseCase>(),
      addProductUseCase: sl<AddProductUseCase>(),
      updateProductUseCase: sl<UpdateProductUseCase>(),
      deleteProductUseCase: sl<DeleteProductUseCase>(),
    ),
  );
  
  sl.registerLazySingleton<AdminSocketClient>(
    () => AdminSocketClient(sl<AuthTokenStorage>()),
  );
  sl.registerFactory<GetAdminNotificationsUseCase>(
    () => GetAdminNotificationsUseCase(sl<AdminRepository>()),
  );
  sl.registerFactory<MarkAllAdminNotificationsAsReadUseCase>(
    () => MarkAllAdminNotificationsAsReadUseCase(sl<AdminRepository>()),
  );
  sl.registerFactory<AdminNotificationCubit>(
    () => AdminNotificationCubit(
      sl<AdminSocketClient>(),
      sl<GetAdminNotificationsUseCase>(),
      sl<MarkAllAdminNotificationsAsReadUseCase>(),
    ),
  );
}
