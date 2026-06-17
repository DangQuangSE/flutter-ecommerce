import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/utils/customer_order_filter.dart';
import 'package:flutter_ecommerce/features/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:flutter_ecommerce/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_event.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  static const int defaultPageSize = 10;

  final GetOrdersUseCase _getOrdersUseCase;
  final GetOrderByIdUseCase _getOrderByIdUseCase;

  OrderBloc({
    required GetOrdersUseCase getOrdersUseCase,
    required GetOrderByIdUseCase getOrderByIdUseCase,
  })  : _getOrdersUseCase = getOrdersUseCase,
        _getOrderByIdUseCase = getOrderByIdUseCase,
        super(const OrderInitial()) {
    on<OrderListRequested>(_onListRequested);
    on<OrderListLoadMoreRequested>(_onLoadMoreRequested);
    on<OrderFilterChanged>(_onFilterChanged);
    on<OrderDetailRequested>(_onDetailRequested);
  }

  Future<void> _onListRequested(
    OrderListRequested event,
    Emitter<OrderState> emit,
  ) async {
    final selectedFilter = state is OrderListLoaded
        ? (state as OrderListLoaded).selectedFilter
        : CustomerOrderFilter.defaultPill;

    emit(const OrderListLoading());

    final result = await _getOrdersUseCase(page: 0, size: defaultPageSize);

    switch (result) {
      case Success(:final data):
        final filtered =
            CustomerOrderFilter.apply(selectedFilter, data.content);
        emit(OrderListLoaded(
          orders: filtered,
          allOrders: data.content,
          selectedFilter: selectedFilter,
          page: data.page,
          isLast: data.isLast,
        ));
      case ResultFailure(:final failure):
        emit(OrderListError(failure.message));
    }
  }

  Future<void> _onLoadMoreRequested(
    OrderListLoadMoreRequested event,
    Emitter<OrderState> emit,
  ) async {
    final current = state;
    if (current is! OrderListLoaded ||
        current.isLast ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, clearMessage: true));

    final result = await _getOrdersUseCase(
      page: current.page + 1,
      size: defaultPageSize,
    );

    switch (result) {
      case Success(:final data):
        final allOrders = [...current.allOrders, ...data.content];
        final filtered =
            CustomerOrderFilter.apply(current.selectedFilter, allOrders);
        emit(OrderListLoaded(
          orders: filtered,
          allOrders: allOrders,
          selectedFilter: current.selectedFilter,
          page: data.page,
          isLast: data.isLast,
        ));
      case ResultFailure(:final failure):
        emit(current.copyWith(
          isLoadingMore: false,
          message: failure.message,
        ));
    }
  }

  void _onFilterChanged(
    OrderFilterChanged event,
    Emitter<OrderState> emit,
  ) {
    final current = state;
    if (current is! OrderListLoaded) return;

    final filtered = CustomerOrderFilter.apply(event.pill, current.allOrders);
    emit(current.copyWith(
      orders: filtered,
      selectedFilter: event.pill,
      clearMessage: true,
    ));
  }

  Future<void> _onDetailRequested(
    OrderDetailRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderDetailLoading());

    final result = await _getOrderByIdUseCase(event.orderId);

    switch (result) {
      case Success(:final data):
        emit(OrderDetailLoaded(order: data));
      case ResultFailure(:final failure):
        emit(OrderDetailError(failure.message));
    }
  }
}
