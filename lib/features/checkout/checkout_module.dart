import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:flutter_ecommerce/features/checkout/data/datasources/checkout_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:flutter_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/create_vnpay_payment_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/verify_vnpay_payment_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';

void setupCheckoutModule(GetIt sl) {
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
}
