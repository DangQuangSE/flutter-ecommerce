import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_order_detail_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_orders_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/update_admin_order_status_usecase.dart';

import 'admin_order_state.dart';

class AdminOrderCubit extends Cubit<AdminOrderState> {
  static const int defaultPageSize = 10;

  final GetAdminOrdersUseCase _getAdminOrdersUseCase;
  final GetAdminOrderDetailUseCase _getAdminOrderDetailUseCase;
  final UpdateAdminOrderStatusUseCase _updateAdminOrderStatusUseCase;

  /// Bumped on every successful status update that can change revenue
  /// eligibility. AdminDashboardPage compares this against the last consumed
  /// value on tab re-entry to decide whether analytics need a refetch.
  int analyticsInvalidationRevision = 0;

  AdminOrderCubit({
    required GetAdminOrdersUseCase getAdminOrdersUseCase,
    required GetAdminOrderDetailUseCase getAdminOrderDetailUseCase,
    required UpdateAdminOrderStatusUseCase updateAdminOrderStatusUseCase,
  })  : _getAdminOrdersUseCase = getAdminOrdersUseCase,
        _getAdminOrderDetailUseCase = getAdminOrderDetailUseCase,
        _updateAdminOrderStatusUseCase = updateAdminOrderStatusUseCase,
        super(const AdminOrderInitial());

  Future<void> loadOrders({bool reset = true}) async {
    final current = state;
    final search = current is AdminOrderListLoaded ? current.search : null;
    final statusFilter =
        current is AdminOrderListLoaded ? current.statusFilter : null;
    final startDateFilter =
        current is AdminOrderListLoaded ? current.startDateFilter : null;
    final endDateFilter =
        current is AdminOrderListLoaded ? current.endDateFilter : null;

    if (reset) {
      emit(const AdminOrderListLoading());
    }

    if (_hasDateFilter(startDateFilter, endDateFilter)) {
      final filteredResult = await _loadOrdersByDateRange(
        search: search,
        status: statusFilter,
        startDate: startDateFilter,
        endDate: endDateFilter,
      );
      if (filteredResult.error != null) {
        emit(AdminOrderListError(filteredResult.error!));
        return;
      }
      emit(AdminOrderListLoaded(
        orders: filteredResult.orders,
        page: 0,
        isLast: true,
        search: search,
        statusFilter: statusFilter,
        startDateFilter: startDateFilter,
        endDateFilter: endDateFilter,
      ));
      return;
    }

    final result = await _getAdminOrdersUseCase(
      search: search,
      status: statusFilter,
      page: 0,
      size: defaultPageSize,
    );

    switch (result) {
      case Success(:final data):
        emit(AdminOrderListLoaded(
          orders: data.content,
          page: data.page,
          isLast: data.isLast,
          search: search,
          statusFilter: statusFilter,
          startDateFilter: startDateFilter,
          endDateFilter: endDateFilter,
        ));
      case ResultFailure(:final failure):
        emit(AdminOrderListError(failure.message));
    }
  }

  Future<void> loadMoreOrders() async {
    final current = state;
    if (current is! AdminOrderListLoaded ||
        current.isLast ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, clearMessage: true));

    final result = await _getAdminOrdersUseCase(
      search: current.search,
      status: current.statusFilter,
      page: current.page + 1,
      size: defaultPageSize,
    );

    switch (result) {
      case Success(:final data):
        emit(AdminOrderListLoaded(
          orders: [
            ...current.orders,
            ..._filterByDateRange(
              data.content,
              current.startDateFilter,
              current.endDateFilter,
            ),
          ],
          page: data.page,
          isLast: data.isLast,
          search: current.search,
          statusFilter: current.statusFilter,
          startDateFilter: current.startDateFilter,
          endDateFilter: current.endDateFilter,
        ));
      case ResultFailure(:final failure):
        emit(current.copyWith(
          isLoadingMore: false,
          message: failure.message,
        ));
    }
  }

  Future<void> applyFilters({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) async {
    final current = state;
    final currentStartDate =
        current is AdminOrderListLoaded ? current.startDateFilter : null;
    final currentEndDate =
        current is AdminOrderListLoaded ? current.endDateFilter : null;
    final startDateFilter =
        clearStartDate ? null : (startDate ?? currentStartDate);
    final endDateFilter = clearEndDate ? null : (endDate ?? currentEndDate);
    emit(const AdminOrderListLoading());

    if (_hasDateFilter(startDateFilter, endDateFilter)) {
      final filteredResult = await _loadOrdersByDateRange(
        search: search,
        status: status?.isEmpty == true ? null : status,
        startDate: startDateFilter,
        endDate: endDateFilter,
      );
      if (filteredResult.error != null) {
        emit(AdminOrderListError(filteredResult.error!));
        return;
      }
      emit(AdminOrderListLoaded(
        orders: filteredResult.orders,
        page: 0,
        isLast: true,
        search: search,
        statusFilter: status?.isEmpty == true ? null : status,
        startDateFilter: startDateFilter,
        endDateFilter: endDateFilter,
      ));
      return;
    }

    final result = await _getAdminOrdersUseCase(
      search: search,
      status: status?.isEmpty == true ? null : status,
      page: 0,
      size: defaultPageSize,
    );

    switch (result) {
      case Success(:final data):
        emit(AdminOrderListLoaded(
          orders: data.content,
          page: data.page,
          isLast: data.isLast,
          search: search,
          statusFilter: status?.isEmpty == true ? null : status,
          startDateFilter: startDateFilter,
          endDateFilter: endDateFilter,
        ));
      case ResultFailure(:final failure):
        emit(AdminOrderListError(failure.message));
    }
  }

  Future<void> loadOrderDetail(int id) async {
    emit(const AdminOrderDetailLoading());

    final result = await _getAdminOrderDetailUseCase(id);
    switch (result) {
      case Success(:final data):
        emit(AdminOrderDetailLoaded(order: data));
      case ResultFailure(:final failure):
        emit(AdminOrderDetailError(failure.message));
    }
  }

  Future<void> updateStatus(int orderId, String newStatus) async {
    final current = state;
    if (current is! AdminOrderDetailLoaded) return;

    emit(current.copyWith(isUpdatingStatus: true, clearMessage: true));

    final result = await _updateAdminOrderStatusUseCase(
      orderId: orderId,
      status: newStatus,
    );

    switch (result) {
      case Success():
        final detailResult = await _getAdminOrderDetailUseCase(orderId);
        switch (detailResult) {
          case Success(:final data):
            analyticsInvalidationRevision++;
            emit(AdminOrderDetailLoaded(
              order: data,
              message: AppStrings.adminOrderUpdateStatusSuccess,
            ));
          case ResultFailure(:final failure):
            emit(current.copyWith(
              isUpdatingStatus: false,
              message: failure.message,
            ));
        }
      case ResultFailure(:final failure):
        emit(current.copyWith(
          isUpdatingStatus: false,
          message: failure.message,
        ));
    }
  }

  Future<void> refreshList() => loadOrders(reset: true);

  Future<void> refreshDetail(int id) => loadOrderDetail(id);

  Future<({List<AdminOrderEntity> orders, String? error})>
      _loadOrdersByDateRange({
    required String? search,
    required String? status,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    var page = 0;
    var isLast = false;
    final orders = <AdminOrderEntity>[];

    while (!isLast) {
      final result = await _getAdminOrdersUseCase(
        search: search,
        status: status,
        page: page,
        size: defaultPageSize,
      );
      switch (result) {
        case Success(:final data):
          orders.addAll(_filterByDateRange(data.content, startDate, endDate));
          isLast = data.isLast;
          page += 1;
        case ResultFailure(:final failure):
          return (orders: const <AdminOrderEntity>[], error: failure.message);
      }
    }

    return (orders: orders, error: null);
  }

  bool _hasDateFilter(DateTime? startDate, DateTime? endDate) =>
      startDate != null || endDate != null;

  List<AdminOrderEntity> _filterByDateRange(
    List<AdminOrderEntity> orders,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return orders;

    return orders.where((order) {
      final createdAt = order.createdAt;
      final startsAt = startDate == null
          ? null
          : DateTime(startDate.year, startDate.month, startDate.day);
      final endsAt = endDate == null
          ? null
          : DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      final afterStart = startsAt == null || !createdAt.isBefore(startsAt);
      final beforeEnd = endsAt == null || !createdAt.isAfter(endsAt);
      return afterStart && beforeEnd;
    }).toList();
  }
}
