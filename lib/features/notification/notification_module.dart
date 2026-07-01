import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:flutter_ecommerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter_ecommerce/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_cubit.dart';

void setupNotificationModule(GetIt sl) {
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );
  sl.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(
      getNotificationsUseCase: sl<GetNotificationsUseCase>(),
      repository: sl<NotificationRepository>(),
    ),
  );
}
