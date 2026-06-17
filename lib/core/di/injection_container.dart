import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

// Admin Product
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_variant_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_variant_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_image_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_image_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/product/data/repositories/admin_product_repository_impl.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/repositories/admin_product_repository.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/get_admin_products_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/get_admin_product_detail_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/update_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_variant_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_variants_batch_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/update_variant_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_variant_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/add_product_image_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_product_image_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/bloc/admin_product_list_bloc.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';

// Checkout
import 'package:flutter_ecommerce/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:flutter_ecommerce/features/checkout/data/datasources/checkout_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:flutter_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/create_vnpay_payment_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/verify_vnpay_payment_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';

// Auth
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/data/datasources/forgot_password_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/data/datasources/forgot_password_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/data/repositories/forgot_password_repository_impl.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/repositories/forgot_password_repository.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/usecases/forgot_password_request_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/usecases/forgot_password_reset_usecase.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/usecases/forgot_password_verify_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_bloc.dart';

// Product
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/product/data/repositories/product_repository_impl.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';
import 'package:flutter_ecommerce/features/customizer/data/datasources/custom_design_remote_datasource.dart';
import 'package:flutter_ecommerce/features/customizer/data/datasources/custom_design_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/customizer/data/repositories/custom_design_repository_impl.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_existing_design_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_printing_configs_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/save_custom_design_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_product_catalog_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/add_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/update_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/delete_product_usecase.dart';

// Admin
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_repository.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_stats_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_orders_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_order_detail_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/update_admin_order_status_usecase.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_order_remote_datasource.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_order_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_order_repository.dart';
import 'package:flutter_ecommerce/features/admin/data/repositories/admin_order_repository_impl.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';

// Size Group
import 'package:flutter_ecommerce/features/size/data/datasources/size_group_remote_datasource.dart';
import 'package:flutter_ecommerce/features/size/data/datasources/size_group_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/size/data/repositories/size_group_repository_impl.dart';
import 'package:flutter_ecommerce/features/size/domain/repositories/size_group_repository.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/get_size_groups_usecase.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/create_size_group_usecase.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/update_size_group_usecase.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/delete_size_group_usecase.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';

// Brand
import 'package:flutter_ecommerce/features/brand/data/datasources/brand_remote_datasource.dart';
import 'package:flutter_ecommerce/features/brand/data/datasources/brand_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/brand/data/repositories/brand_repository_impl.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';
import 'package:flutter_ecommerce/features/brand/presentation/cubit/brand_cubit.dart';

// Site Setting
import 'package:flutter_ecommerce/features/setting/data/datasources/site_setting_remote_datasource.dart';
import 'package:flutter_ecommerce/features/setting/data/datasources/site_setting_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/setting/data/repositories/site_setting_repository_impl.dart';
import 'package:flutter_ecommerce/features/setting/domain/repositories/site_setting_repository.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_cubit.dart';

// Review
import 'package:flutter_ecommerce/features/review/data/datasources/review_remote_datasource.dart';
import 'package:flutter_ecommerce/features/review/data/datasources/review_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/review/data/repositories/review_repository_impl.dart';
import 'package:flutter_ecommerce/features/review/domain/repositories/review_repository.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/admin_review_cubit.dart';

// Color
import 'package:flutter_ecommerce/features/color/data/datasources/product_color_remote_datasource.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/product_color_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/color/data/repositories/product_color_repository_impl.dart';
import 'package:flutter_ecommerce/features/color/domain/repositories/product_color_repository.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';

import 'package:flutter_ecommerce/features/color/data/datasources/printing_color_remote_datasource.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/printing_color_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/color/data/repositories/printing_color_repository_impl.dart';
import 'package:flutter_ecommerce/features/color/domain/repositories/printing_color_repository.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/printing_color_cubit.dart';

// Category
import 'package:flutter_ecommerce/features/category/data/network/category_api_client.dart';
import 'package:flutter_ecommerce/features/category/data/datasources/category_remote_datasource.dart';
import 'package:flutter_ecommerce/features/category/data/repositories/category_repository_impl.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';

// Coupon
import 'package:flutter_ecommerce/features/coupon/data/datasources/coupon_remote_datasource.dart';
import 'package:flutter_ecommerce/features/coupon/data/repositories/coupon_repository_impl.dart';
import 'package:flutter_ecommerce/features/coupon/domain/repositories/coupon_repository.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';

// Cart
import 'package:flutter_ecommerce/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:flutter_ecommerce/features/cart/data/datasources/cart_remote_datasource_impl.dart';
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
import 'package:flutter_ecommerce/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:flutter_ecommerce/features/chat/data/datasources/chat_socket_client.dart';
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
  sl.registerLazySingleton<AuthTokenStorage>(
    () => AuthTokenStorage(sl<LocalStorage>()),
  );

  final CookieJar cookieJar;
  if (kIsWeb) {
    cookieJar = CookieJar();
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );
  }
  sl.registerSingleton<CookieJar>(cookieJar);

  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      localStorage: sl<LocalStorage>(),
      authTokenStorage: sl<AuthTokenStorage>(),
      cookieJar: sl<CookieJar>(),
    ),
  );

  // ── Auth ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sl<AuthTokenStorage>(), sl<CookieJar>()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<AuthLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory<RequestOtpUseCase>(
    () => RequestOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory<ResendOtpUseCase>(
    () => ResendOtpUseCase(sl<AuthRepository>()),
  );
  // Singleton — router's refresh stream reads from this one instance
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      requestOtpUseCase: sl<RequestOtpUseCase>(),
      verifyOtpUseCase: sl<VerifyOtpUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      resendOtpUseCase: sl<ResendOtpUseCase>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // ── Forgot password ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<ForgotPasswordRemoteDataSource>(
    () => ForgotPasswordRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ForgotPasswordRepository>(
    () => ForgotPasswordRepositoryImpl(sl<ForgotPasswordRemoteDataSource>()),
  );
  sl.registerFactory<ForgotPasswordRequestOtpUseCase>(
    () => ForgotPasswordRequestOtpUseCase(sl<ForgotPasswordRepository>()),
  );
  sl.registerFactory<ForgotPasswordVerifyOtpUseCase>(
    () => ForgotPasswordVerifyOtpUseCase(sl<ForgotPasswordRepository>()),
  );
  sl.registerFactory<ForgotPasswordResetUseCase>(
    () => ForgotPasswordResetUseCase(sl<ForgotPasswordRepository>()),
  );
  sl.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(
      requestOtpUseCase: sl<ForgotPasswordRequestOtpUseCase>(),
      verifyOtpUseCase: sl<ForgotPasswordVerifyOtpUseCase>(),
      resetUseCase: sl<ForgotPasswordResetUseCase>(),
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
  sl.registerLazySingleton<GetProductCatalogUseCase>(
    () => GetProductCatalogUseCase(sl<ProductRepository>()),
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
  sl.registerFactory<ProductCatalogBloc>(
    () => ProductCatalogBloc(sl<GetProductCatalogUseCase>()),
  );
  sl.registerLazySingleton<CustomDesignRemoteDataSource>(
    () => CustomDesignRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<CustomDesignRepository>(
    () => CustomDesignRepositoryImpl(sl<CustomDesignRemoteDataSource>()),
  );
  sl.registerLazySingleton<SaveCustomDesignUseCase>(
    () => SaveCustomDesignUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerLazySingleton<GetPrintingConfigsUseCase>(
    () => GetPrintingConfigsUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerLazySingleton<GetExistingDesignUseCase>(
    () => GetExistingDesignUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerFactory<CustomizerCubit>(
    () => CustomizerCubit(
      getPrintingConfigs: sl<GetPrintingConfigsUseCase>(),
      saveCustomDesign: sl<SaveCustomDesignUseCase>(),
      getExistingDesign: sl<GetExistingDesignUseCase>(),
    ),
  );

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

  // Size Group Management
  sl.registerLazySingleton<SizeGroupRemoteDatasource>(
    () => SizeGroupRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SizeGroupRepository>(
    () => SizeGroupRepositoryImpl(sl<SizeGroupRemoteDatasource>()),
  );
  sl.registerFactory<GetSizeGroupsUseCase>(
    () => GetSizeGroupsUseCase(sl<SizeGroupRepository>()),
  );
  sl.registerFactory<CreateSizeGroupUseCase>(
    () => CreateSizeGroupUseCase(sl<SizeGroupRepository>()),
  );
  sl.registerFactory<UpdateSizeGroupUseCase>(
    () => UpdateSizeGroupUseCase(sl<SizeGroupRepository>()),
  );
  sl.registerFactory<DeleteSizeGroupUseCase>(
    () => DeleteSizeGroupUseCase(sl<SizeGroupRepository>()),
  );
  sl.registerFactory<SizeGroupCubit>(
    () => SizeGroupCubit(
      getSizeGroupsUseCase: sl<GetSizeGroupsUseCase>(),
      createSizeGroupUseCase: sl<CreateSizeGroupUseCase>(),
      updateSizeGroupUseCase: sl<UpdateSizeGroupUseCase>(),
      deleteSizeGroupUseCase: sl<DeleteSizeGroupUseCase>(),
    ),
  );

  // Brand Management
  sl.registerLazySingleton<BrandRemoteDataSource>(
    () => BrandRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<BrandRepository>(
    () => BrandRepositoryImpl(sl<BrandRemoteDataSource>()),
  );
  sl.registerFactory<BrandCubit>(
    () => BrandCubit(sl<BrandRepository>()),
  );

  // Site Setting
  sl.registerLazySingleton<SiteSettingRemoteDataSource>(
    () => SiteSettingRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SiteSettingRepository>(
    () => SiteSettingRepositoryImpl(sl<SiteSettingRemoteDataSource>()),
  );
  sl.registerFactory<SiteSettingCubit>(
    () => SiteSettingCubit(sl<SiteSettingRepository>()),
  );

  // Review
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl<ReviewRemoteDataSource>()),
  );
  sl.registerFactory<ReviewCubit>(
    () => ReviewCubit(sl<ReviewRepository>()),
  );
  sl.registerFactory<AdminReviewCubit>(
    () => AdminReviewCubit(sl<ReviewRepository>()),
  );

  // Product Color Management
  sl.registerLazySingleton<ProductColorRemoteDataSource>(
    () => ProductColorRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ProductColorRepository>(
    () => ProductColorRepositoryImpl(sl<ProductColorRemoteDataSource>()),
  );
  sl.registerFactory<ProductColorCubit>(
    () => ProductColorCubit(sl<ProductColorRepository>()),
  );

  // Printing Color Management
  sl.registerLazySingleton<PrintingColorRemoteDataSource>(
    () => PrintingColorRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<PrintingColorRepository>(
    () => PrintingColorRepositoryImpl(sl<PrintingColorRemoteDataSource>()),
  );
  sl.registerFactory<PrintingColorCubit>(
    () => PrintingColorCubit(sl<PrintingColorRepository>()),
  );

  // Category Management — uses its own backend client (self-contained auth)
  sl.registerLazySingleton<CategoryApiClient>(
    () => CategoryApiClient(sl<LocalStorage>()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl<CategoryApiClient>()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
  );
  sl.registerFactory<CategoryCubit>(
    () => CategoryCubit(sl<CategoryRepository>()),
  );

  // Coupon Management — admin-only, over the shared DioClient
  sl.registerLazySingleton<CouponRemoteDataSource>(
    () => CouponRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<CouponRepository>(
    () => CouponRepositoryImpl(sl<CouponRemoteDataSource>()),
  );
  sl.registerFactory<CouponCubit>(
    () => CouponCubit(sl<CouponRepository>()),
  );

  // ── Cart ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartRemoteDataSource>()),
  );
  sl.registerLazySingleton<CartCubit>(() => CartCubit(sl<CartRepository>()));

  // ── Profile ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileCubit>(() => ProfileCubit());

  // ── Notification ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl());
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
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ChatSocketClient>(
    () => ChatSocketClient(sl<AuthTokenStorage>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () =>
        ChatRepositoryImpl(sl<ChatRemoteDataSource>(), sl<ChatSocketClient>()),
  );
  sl.registerLazySingleton<GetChatsUseCase>(
      () => GetChatsUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<GetMessagesUseCase>(
      () => GetMessagesUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<ChatCubit>(
    () => ChatCubit(
      getChatsUseCase: sl<GetChatsUseCase>(),
      getMessagesUseCase: sl<GetMessagesUseCase>(),
      sendMessageUseCase: sl<SendMessageUseCase>(),
      repository: sl<ChatRepository>(),
    ),
  );

  // ── Checkout / VNPay ───────────────────────────────────────────────────────
  sl.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(sl<CheckoutRemoteDataSource>()),
  );
  sl.registerFactory<PlaceOrderUseCase>(
    () => PlaceOrderUseCase(sl<CheckoutRepository>()),
  );
  sl.registerFactory<CreateVnpayPaymentUseCase>(
    () => CreateVnpayPaymentUseCase(sl<CheckoutRepository>()),
  );
  sl.registerFactory<VerifyVnpayPaymentUseCase>(
    () => VerifyVnpayPaymentUseCase(sl<CheckoutRepository>()),
  );
  sl.registerFactory<CheckoutBloc>(
    () => CheckoutBloc(
      placeOrderUseCase: sl<PlaceOrderUseCase>(),
      createVnpayPaymentUseCase: sl<CreateVnpayPaymentUseCase>(),
      verifyVnpayPaymentUseCase: sl<VerifyVnpayPaymentUseCase>(),
    ),
  );

  // ── Admin Product ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AdminProductDatasource>(
    () => AdminProductDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminProductVariantDatasource>(
    () => AdminProductVariantDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminProductImageDatasource>(
    () => AdminProductImageDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminProductRepository>(
    () => AdminProductRepositoryImpl(
      sl<AdminProductDatasource>(),
      sl<AdminProductVariantDatasource>(),
      sl<AdminProductImageDatasource>(),
    ),
  );
  sl.registerLazySingleton<GetAdminProductsUseCase>(
    () => GetAdminProductsUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<GetAdminProductDetailUseCase>(
    () => GetAdminProductDetailUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<CreateProductUseCase>(
    () => CreateProductUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<UpdateAdminProductUseCase>(
    () => UpdateAdminProductUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<DeleteAdminProductUseCase>(
    () => DeleteAdminProductUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<CreateVariantUseCase>(
    () => CreateVariantUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<CreateVariantsBatchUseCase>(
    () => CreateVariantsBatchUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<UpdateVariantUseCase>(
    () => UpdateVariantUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<DeleteVariantUseCase>(
    () => DeleteVariantUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<AddProductImageUseCase>(
    () => AddProductImageUseCase(sl<AdminProductRepository>()),
  );
  sl.registerLazySingleton<DeleteProductImageUseCase>(
    () => DeleteProductImageUseCase(sl<AdminProductRepository>()),
  );
  sl.registerFactory<AdminProductListBloc>(
    () => AdminProductListBloc(
      sl<GetAdminProductsUseCase>(),
      sl<DeleteAdminProductUseCase>(),
    ),
  );
  sl.registerFactory<AdminProductDetailCubit>(
    () => AdminProductDetailCubit(sl<GetAdminProductDetailUseCase>()),
  );
  sl.registerFactory<AdminProductFormCubit>(
    () => AdminProductFormCubit(
      sl<CreateProductUseCase>(),
      sl<UpdateAdminProductUseCase>(),
      sl<DeleteAdminProductUseCase>(),
      sl<CategoryRepository>(),
      sl<BrandRepository>(),
      sl<GetSizeGroupsUseCase>(),
    ),
  );
  sl.registerFactory<AdminProductVariantCubit>(
    () => AdminProductVariantCubit(
      sl<CreateVariantUseCase>(),
      sl<CreateVariantsBatchUseCase>(),
      sl<UpdateVariantUseCase>(),
      sl<DeleteVariantUseCase>(),
    ),
  );
  sl.registerFactory<AdminProductImageCubit>(
    () => AdminProductImageCubit(
      sl<AddProductImageUseCase>(),
      sl<DeleteProductImageUseCase>(),
    ),
  );
}
