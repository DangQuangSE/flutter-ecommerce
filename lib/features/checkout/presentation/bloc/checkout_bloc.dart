import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/create_vnpay_payment_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/verify_vnpay_payment_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final PlaceOrderUseCase _placeOrderUseCase;
  final CreateVnpayPaymentUseCase _createVnpayPaymentUseCase;
  final VerifyVnpayPaymentUseCase _verifyVnpayPaymentUseCase;

  static const _maxVerifyAttempts = 3;
  static const _verifyRetryDelay = Duration(seconds: 2);

  CheckoutBloc({
    required PlaceOrderUseCase placeOrderUseCase,
    required CreateVnpayPaymentUseCase createVnpayPaymentUseCase,
    required VerifyVnpayPaymentUseCase verifyVnpayPaymentUseCase,
  })  : _placeOrderUseCase = placeOrderUseCase,
        _createVnpayPaymentUseCase = createVnpayPaymentUseCase,
        _verifyVnpayPaymentUseCase = verifyVnpayPaymentUseCase,
        super(const CheckoutInitial()) {
    on<CheckoutSubmitted>(_onSubmitted);
    on<CheckoutPaymentReturned>(_onPaymentReturned);
    on<CheckoutRetryVerify>(_onRetryVerify);
  }

  Future<void> _onSubmitted(
    CheckoutSubmitted event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(const CheckoutLoading());

    final placeResult = await _placeOrderUseCase(event.request);
    switch (placeResult) {
      case Success(:final data):
        final orderId = data;
        final paymentResult = await _createVnpayPaymentUseCase(orderId);
        switch (paymentResult) {
          case Success(:final data):
            emit(CheckoutAwaitingPayment(data));
          case ResultFailure(:final failure):
            emit(CheckoutFailure(failure.message));
        }
      case ResultFailure(:final failure):
        emit(CheckoutFailure(failure.message));
    }
  }

  Future<void> _onPaymentReturned(
    CheckoutPaymentReturned event,
    Emitter<CheckoutState> emit,
  ) async {
    if (event.result == null) {
      emit(const CheckoutFailure('Bạn đã hủy thanh toán VNPay.'));
      return;
    }
    await _verifyWithRetry(event.orderId, emit);
  }

  Future<void> _onRetryVerify(
    CheckoutRetryVerify event,
    Emitter<CheckoutState> emit,
  ) async {
    await _verifyWithRetry(event.orderId, emit);
  }

  Future<void> _verifyWithRetry(
    int orderId,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutVerifying(orderId));

    for (var attempt = 0; attempt < _maxVerifyAttempts; attempt++) {
      final verifyResult = await _verifyVnpayPaymentUseCase(orderId);
      switch (verifyResult) {
        case Success(:final data):
          if (data.isSuccess) {
            emit(CheckoutSuccess(orderId));
            return;
          }
          if (data.isFailed) {
            emit(const CheckoutFailure('Thanh toán VNPay không thành công.'));
            return;
          }
        case ResultFailure(:final failure):
          emit(CheckoutFailure(failure.message));
          return;
      }

      if (attempt < _maxVerifyAttempts - 1) {
        await Future<void>.delayed(_verifyRetryDelay);
      }
    }

    emit(const CheckoutFailure(
      'Đang xác nhận thanh toán. Vui lòng kiểm tra lại đơn hàng sau vài phút.',
    ));
  }
}
