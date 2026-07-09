import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:flutter_ecommerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter_ecommerce/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter_ecommerce/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:flutter_ecommerce/features/notification/data/datasources/notification_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/features/notification/data/datasources/notification_socket_client.dart';
import 'package:flutter_ecommerce/core/utils/notification_service.dart';

void setupNotificationModule(GetIt sl) {
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<NotificationSocketClient>(
    () => NotificationSocketClient(sl<AuthTokenStorage>()),
  );
  sl.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(
      getNotificationsUseCase: sl<GetNotificationsUseCase>(),
      repository: sl<NotificationRepository>(),
      socketClient: sl<NotificationSocketClient>(),
      notificationService: sl<NotificationService>(),
    ),
  );
}
