import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';

sealed class AdminOrderState extends Equatable {
  const AdminOrderState();

  @override
  List<Object?> get props => [];
}

class AdminOrderInitial extends AdminOrderState {
  const AdminOrderInitial();
}

class AdminOrderListLoading extends AdminOrderState {
  const AdminOrderListLoading();
}

class AdminOrderListLoaded extends AdminOrderState {
  final List<AdminOrderEntity> orders;
  final int page;
  final bool isLast;
  final bool isLoadingMore;
  final String? search;
  final String? statusFilter;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;
  final String? message;

  const AdminOrderListLoaded({
    required this.orders,
    required this.page,
    required this.isLast,
    this.isLoadingMore = false,
    this.search,
    this.statusFilter,
    this.startDateFilter,
    this.endDateFilter,
    this.message,
  });

  AdminOrderListLoaded copyWith({
    List<AdminOrderEntity>? orders,
    int? page,
    bool? isLast,
    bool? isLoadingMore,
    String? search,
    String? statusFilter,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
    String? message,
    bool clearMessage = false,
    bool clearStartDateFilter = false,
    bool clearEndDateFilter = false,
  }) {
    return AdminOrderListLoaded(
      orders: orders ?? this.orders,
      page: page ?? this.page,
      isLast: isLast ?? this.isLast,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      startDateFilter: clearStartDateFilter
          ? null
          : (startDateFilter ?? this.startDateFilter),
      endDateFilter:
          clearEndDateFilter ? null : (endDateFilter ?? this.endDateFilter),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        orders,
        page,
        isLast,
        isLoadingMore,
        search,
        statusFilter,
        startDateFilter,
        endDateFilter,
        message,
      ];
}

class AdminOrderListError extends AdminOrderState {
  final String message;

  const AdminOrderListError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminOrderDetailLoading extends AdminOrderState {
  const AdminOrderDetailLoading();
}

class AdminOrderDetailLoaded extends AdminOrderState {
  final AdminOrderEntity order;
  final bool isUpdatingStatus;
  final String? message;

  const AdminOrderDetailLoaded({
    required this.order,
    this.isUpdatingStatus = false,
    this.message,
  });

  AdminOrderDetailLoaded copyWith({
    AdminOrderEntity? order,
    bool? isUpdatingStatus,
    String? message,
    bool clearMessage = false,
  }) {
    return AdminOrderDetailLoaded(
      order: order ?? this.order,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [order, isUpdatingStatus, message];
}

class AdminOrderDetailError extends AdminOrderState {
  final String message;

  const AdminOrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
