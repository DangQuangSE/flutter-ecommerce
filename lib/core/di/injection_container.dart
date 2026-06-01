import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

// Auth
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';

// Product
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/product/data/repositories/product_repository_impl.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/add_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/update_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/delete_product_usecase.dart';

// Admin
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_repository.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_stats_usecase.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/customizer_cubit.dart';

// Cart
import 'package:flutter_ecommerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:flutter_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';

// Profile
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_cubit.dart';

// Notification
import 'package:flutter_ecommerce/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:flutter_ecommerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter_ecommerce/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_cubit.dart';

// Chat
import 'package:flutter_ecommerce/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_ecommerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_ecommerce/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:flutter_ecommerce/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_ecommerce/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── External ────────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ── Core ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<LocalStorage>(
    () => LocalStorage(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ── Auth ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  // Singleton — router's refresh stream reads from this one instance
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // ── Product ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<AddProductUseCase>(
    () => AddProductUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<DeleteProductUseCase>(
    () => DeleteProductUseCase(sl<ProductRepository>()),
  );
  // Factory — each product route gets its own BLoC instance
  sl.registerFactory<ProductBloc>(
    () => ProductBloc(
      getProductsUseCase: sl<GetProductsUseCase>(),
      productRepository: sl<ProductRepository>(),
    ),
  );
  sl.registerLazySingleton<CustomizerCubit>(() => CustomizerCubit());

  // ── Admin ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAdminStatsUseCase>(
    () => GetAdminStatsUseCase(sl<AdminRepository>()),
  );
  sl.registerFactory<AdminBloc>(
    () => AdminBloc(
      getAdminStatsUseCase: sl<GetAdminStatsUseCase>(),
      getProductsUseCase: sl<GetProductsUseCase>(),
      addProductUseCase: sl<AddProductUseCase>(),
      updateProductUseCase: sl<UpdateProductUseCase>(),
      deleteProductUseCase: sl<DeleteProductUseCase>(),
    ),
  );

  // ── Cart ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl());
  sl.registerLazySingleton<CartCubit>(() => CartCubit(sl<CartRepository>()));

  // ── Profile ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileCubit>(() => ProfileCubit());

  // ── Notification ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl());
  sl.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(
      getNotificationsUseCase: sl<GetNotificationsUseCase>(),
      repository: sl<NotificationRepository>(),
    ),
  );

  // ── Chat ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl());
  sl.registerLazySingleton<GetChatsUseCase>(() => GetChatsUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<GetMessagesUseCase>(() => GetMessagesUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<SendMessageUseCase>(() => SendMessageUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<ChatCubit>(
    () => ChatCubit(
      getChatsUseCase: sl<GetChatsUseCase>(),
      getMessagesUseCase: sl<GetMessagesUseCase>(),
      sendMessageUseCase: sl<SendMessageUseCase>(),
      repository: sl<ChatRepository>(),
    ),
  );

  // Checkout / Order — register when implementations are added
}
