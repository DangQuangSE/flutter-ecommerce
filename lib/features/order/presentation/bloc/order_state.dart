import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';

sealed class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderListLoading extends OrderState {
  const OrderListLoading();
}

class OrderListLoaded extends OrderState {
  final List<OrderEntity> orders;
  final List<OrderEntity> allOrders;
  final String selectedFilter;
  final int page;
  final bool isLast;
  final bool isLoadingMore;
  final String? message;

  const OrderListLoaded({
    required this.orders,
    required this.allOrders,
    required this.selectedFilter,
    required this.page,
    required this.isLast,
    this.isLoadingMore = false,
    this.message,
  });

  OrderListLoaded copyWith({
    List<OrderEntity>? orders,
    List<OrderEntity>? allOrders,
    String? selectedFilter,
    int? page,
    bool? isLast,
    bool? isLoadingMore,
    String? message,
    bool clearMessage = false,
  }) {
    return OrderListLoaded(
      orders: orders ?? this.orders,
      allOrders: allOrders ?? this.allOrders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      page: page ?? this.page,
      isLast: isLast ?? this.isLast,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        orders,
        allOrders,
        selectedFilter,
        page,
        isLast,
        isLoadingMore,
        message,
      ];
}

class OrderListError extends OrderState {
  final String message;

  const OrderListError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderDetailLoading extends OrderState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderState {
  final OrderEntity order;

  const OrderDetailLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderDetailError extends OrderState {
  final String message;

  const OrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
