import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/network/dio_error_mapper.dart';
import 'package:flutter_ecommerce/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:flutter_ecommerce/features/checkout/data/models/order_request_model.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_payment_session_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_verify_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource _remoteDataSource;

  const CheckoutRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<int>> placeOrder(OrderRequestEntity request) async {
    try {
      final model = await _remoteDataSource.placeOrder(
        OrderRequestModel.fromEntity(request),
      );
      return Success(model.id);
    } on DioException catch (e) {
      return ResultFailure(failureFromDioException(e));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<VnpayPaymentSessionEntity>> createVnpayPayment(
    int orderId,
  ) async {
    try {
      final model = await _remoteDataSource.createVnpayPayment(orderId);
      return Success(model.toEntity());
    } on DioException catch (e) {
      return ResultFailure(failureFromDioException(e));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<VnpayVerifyEntity>> verifyVnpayPayment(int orderId) async {
    try {
      final model = await _remoteDataSource.verifyVnpayPayment(orderId);
      return Success(model.toEntity());
    } on DioException catch (e) {
      return ResultFailure(failureFromDioException(e));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }
}
