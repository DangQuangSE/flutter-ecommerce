import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/models/paged_result.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';
import 'package:flutter_ecommerce/features/order/domain/repositories/order_repository.dart';
import 'package:flutter_ecommerce/features/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:flutter_ecommerce/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_event.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_state.dart';

class _FakeOrderRepository implements OrderRepository {
  Future<Result<PagedResult<OrderEntity>>> Function({int page, int size})?
      getOrdersHandler;

  @override
  Future<Result<PagedResult<OrderEntity>>> getOrders({
    int page = 0,
    int size = 10,
  }) async {
    return getOrdersHandler!(page: page, size: size);
  }

  @override
  Future<Result<OrderEntity>> getOrderById(int id) {
    throw UnimplementedError();
  }
}

OrderEntity _sampleOrder({int id = 1, String status = 'CONFIRMED'}) =>
    OrderEntity(
      id: id,
      status: status,
      totalAmount: 100000,
      createdAt: DateTime(2026, 6, 1),
      shippingAddress: 'HN',
      phoneNumber: '090',
      paymentMethod: 'COD',
      paymentCompleted: true,
      items: const [],
    );

void main() {
  late _FakeOrderRepository fakeRepo;
  late OrderBloc bloc;

  setUp(() {
    fakeRepo = _FakeOrderRepository();
    bloc = OrderBloc(
      getOrdersUseCase: GetOrdersUseCase(fakeRepo),
      getOrderByIdUseCase: GetOrderByIdUseCase(fakeRepo),
    );
  });

  tearDown(() => bloc.close());

  test('emits loaded state on successful list fetch', () async {
    fakeRepo.getOrdersHandler = ({page = 0, size = 10}) async => Success(
          PagedResult(
            content: [_sampleOrder()],
            totalElements: 1,
            totalPages: 1,
            page: 0,
            isLast: true,
          ),
        );

    final states = <OrderState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const OrderListRequested());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(states[0], isA<OrderListLoading>());
    expect(states.last, isA<OrderListLoaded>());
    final loaded = states.last as OrderListLoaded;
    expect(loaded.orders, hasLength(1));
    expect(loaded.allOrders, hasLength(1));

    await sub.cancel();
  });

  test('emits error state on list fetch failure', () async {
    fakeRepo.getOrdersHandler = ({page = 0, size = 10}) async =>
        const ResultFailure(NetworkFailure('Network error'));

    final states = <OrderState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const OrderListRequested());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(states.last, isA<OrderListError>());
    expect((states.last as OrderListError).message, 'Network error');

    await sub.cancel();
  });

  test('filter change re-filters without extra API call', () async {
    var apiCalls = 0;
    fakeRepo.getOrdersHandler = ({page = 0, size = 10}) async {
      apiCalls++;
      return Success(
        PagedResult(
          content: [
            _sampleOrder(status: 'CONFIRMED'),
            _sampleOrder(id: 2, status: 'SHIPPED'),
          ],
          totalElements: 2,
          totalPages: 1,
          page: 0,
          isLast: true,
        ),
      );
    };

    bloc.add(const OrderListRequested());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    bloc.add(const OrderFilterChanged('Đang giao'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(apiCalls, 1);
    expect(bloc.state, isA<OrderListLoaded>());
    final loaded = bloc.state as OrderListLoaded;
    expect(loaded.orders, hasLength(1));
    expect(loaded.selectedFilter, 'Đang giao');
  });
}
