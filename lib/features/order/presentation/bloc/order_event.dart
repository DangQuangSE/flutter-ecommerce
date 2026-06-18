import 'package:equatable/equatable.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderListRequested extends OrderEvent {
  const OrderListRequested();
}

class OrderListLoadMoreRequested extends OrderEvent {
  const OrderListLoadMoreRequested();
}

class OrderFilterChanged extends OrderEvent {
  final String pill;

  const OrderFilterChanged(this.pill);

  @override
  List<Object?> get props => [pill];
}

class OrderDetailRequested extends OrderEvent {
  final int orderId;

  const OrderDetailRequested(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
