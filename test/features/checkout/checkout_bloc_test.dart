import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/constants/payment_method_constants.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_payment_session_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/vnpay_verify_entity.dart';
import 'package:flutter_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/create_vnpay_payment_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/domain/usecases/verify_vnpay_payment_usecase.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_state.dart';

class _FakeCheckoutRepository implements CheckoutRepository {
  Result<int> Function(OrderRequestEntity request)? placeOrderHandler;
  Future<Result<VnpayPaymentSessionEntity>> Function(int orderId)?
      createVnpayHandler;
  bool createVnpayCalled = false;

  @override
  Future<Result<int>> placeOrder(OrderRequestEntity request) async {
    return placeOrderHandler!(request);
  }

  @override
  Future<Result<VnpayPaymentSessionEntity>> createVnpayPayment(
    int orderId,
  ) async {
    createVnpayCalled = true;
    return createVnpayHandler!(orderId);
  }

  @override
  Future<Result<VnpayVerifyEntity>> verifyVnpayPayment(int orderId) {
    throw UnimplementedError();
  }
}

const _request = OrderRequestEntity(
  shippingAddress: '123 Test St',
  phoneNumber: '0987654321',
  paymentMethod: 'COD',
  cartItemIds: [1],
);

Future<List<CheckoutState>> _collectStates(
  CheckoutBloc bloc,
  Future<void> Function() action,
) async {
  final states = <CheckoutState>[];
  final sub = bloc.stream.listen(states.add);
  await action();
  await sub.cancel();
  return states;
}

void main() {
  late _FakeCheckoutRepository fakeRepo;
  late CheckoutBloc bloc;

  setUp(() {
    fakeRepo = _FakeCheckoutRepository();
    bloc = CheckoutBloc(
      placeOrderUseCase: PlaceOrderUseCase(fakeRepo),
      createVnpayPaymentUseCase: CreateVnpayPaymentUseCase(fakeRepo),
      verifyVnpayPaymentUseCase: VerifyVnpayPaymentUseCase(fakeRepo),
    );
  });

  tearDown(() => bloc.close());

  group('CheckoutPaymentOption', () {
    test('maps COD and VNPay to correct API values', () {
      expect(CheckoutPaymentOption.cod.apiValue, 'COD');
      expect(CheckoutPaymentOption.vnpay.apiValue, 'BANK_TRANSFER');
    });
  });

  group('CheckoutSubmitted COD', () {
    test('emits Success without creating VNPay payment', () async {
      fakeRepo.placeOrderHandler = (_) => const Success(42);

      final states = await _collectStates(bloc, () async {
        bloc.add(const CheckoutSubmitted(_request));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      expect(fakeRepo.createVnpayCalled, isFalse);
      expect(states.length, 2);
      expect(states[0], isA<CheckoutLoading>());
      expect(states[1], isA<CheckoutSuccess>());
      expect((states[1] as CheckoutSuccess).orderId, 42);
    });
  });

  group('CheckoutSubmitted BANK_TRANSFER', () {
    test('emits AwaitingPayment after VNPay create', () async {
      const vnpayRequest = OrderRequestEntity(
        shippingAddress: '123 Test St',
        phoneNumber: '0987654321',
        paymentMethod: 'BANK_TRANSFER',
        cartItemIds: [1],
      );

      fakeRepo.placeOrderHandler = (_) => const Success(7);
      fakeRepo.createVnpayHandler = (_) async => const Success(
            VnpayPaymentSessionEntity(
              orderId: 7,
              txnRef: 'TXN-7',
              paymentUrl: 'https://sandbox.vnpayment.vn/pay',
            ),
          );

      final states = await _collectStates(bloc, () async {
        bloc.add(const CheckoutSubmitted(vnpayRequest));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      expect(fakeRepo.createVnpayCalled, isTrue);
      expect(states.length, 2);
      expect(states[0], isA<CheckoutLoading>());
      expect(states[1], isA<CheckoutAwaitingPayment>());
    });
  });

  group('CheckoutSubmitted invalid payment method', () {
    test('emits Failure for unsupported method', () async {
      const invalidRequest = OrderRequestEntity(
        shippingAddress: '123 Test St',
        phoneNumber: '0987654321',
        paymentMethod: 'CREDIT_CARD',
        cartItemIds: [1],
      );

      fakeRepo.placeOrderHandler = (_) => const Success(1);

      final states = await _collectStates(bloc, () async {
        bloc.add(const CheckoutSubmitted(invalidRequest));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      expect(fakeRepo.createVnpayCalled, isFalse);
      expect(states.last, isA<CheckoutFailure>());
      expect(
        (states.last as CheckoutFailure).message,
        'Phương thức thanh toán không hợp lệ.',
      );
    });
  });

  group('CheckoutSubmitted place order failure', () {
    test('emits Failure when place order fails', () async {
      fakeRepo.placeOrderHandler = (_) => const ResultFailure(
            NetworkFailure('Cart empty'),
          );

      final states = await _collectStates(bloc, () async {
        bloc.add(const CheckoutSubmitted(_request));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      expect(states.last, isA<CheckoutFailure>());
      expect((states.last as CheckoutFailure).message, 'Cart empty');
    });
  });
}
