import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_order_detail_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_orders_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/update_admin_order_status_usecase.dart';

import 'admin_order_state.dart';

class AdminOrderCubit extends Cubit<AdminOrderState> {
  static const int defaultPageSize = 10;

  final GetAdminOrdersUseCase _getAdminOrdersUseCase;
  final GetAdminOrderDetailUseCase _getAdminOrderDetailUseCase;
  final UpdateAdminOrderStatusUseCase _updateAdminOrderStatusUseCase;

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

    if (reset) {
      emit(const AdminOrderListLoading());
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
          orders: [...current.orders, ...data.content],
          page: data.page,
          isLast: data.isLast,
          search: current.search,
          statusFilter: current.statusFilter,
        ));
      case ResultFailure(:final failure):
        emit(current.copyWith(
          isLoadingMore: false,
          message: failure.message,
        ));
    }
  }

  Future<void> applyFilters({String? search, String? status}) async {
    emit(const AdminOrderListLoading());

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
      case Success(:final data):
        emit(AdminOrderDetailLoaded(
          order: data,
          message: 'Đã cập nhật trạng thái đơn hàng!',
        ));
      case ResultFailure(:final failure):
        emit(current.copyWith(
          isUpdatingStatus: false,
          message: failure.message,
        ));
    }
  }

  Future<void> refreshList() => loadOrders(reset: true);

  Future<void> refreshDetail(int id) => loadOrderDetail(id);
}
