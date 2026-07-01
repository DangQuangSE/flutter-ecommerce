import 'package:cookie_jar/cookie_jar.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
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
import 'package:flutter_ecommerce/features/auth/forgot_password/data/datasources/forgot_password_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/data/datasources/forgot_password_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/data/repositories/forgot_password_repository_impl.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/repositories/forgot_password_repository.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/usecases/forgot_password_request_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/usecases/forgot_password_reset_usecase.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/usecases/forgot_password_verify_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';

void setupAuthModule(GetIt sl) {
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
}
