import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/repositories/coupon_repository.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_state.dart';

class CouponCubit extends Cubit<CouponState> {
  final CouponRepository _repository;

  CouponCubit(this._repository) : super(const CouponInitial());

  /// The backend has no server-side search, so we fetch a large page and let
  /// the UI filter by code locally.
  static const int pageSize = 100;

  int _page = 0;

  /// Loads a page of coupons.
  Future<void> load({int page = 0}) async {
    _page = page;
    emit(const CouponLoading());
    final result = await _repository.getCoupons(page: _page, size: pageSize);
    switch (result) {
      case Success(:final data):
        emit(CouponLoaded(
          coupons: data.items,
          page: data.page,
          totalPages: data.totalPages,
          totalElements: data.totalElements,
          isLast: data.isLast,
        ));
      case ResultFailure(:final failure):
        emit(CouponError(failure.message));
    }
  }

  Future<void> loadUserAvailableCoupons() async {
    emit(const CouponLoading());
    final result = await _repository.getUserAvailableCoupons();
    switch (result) {
      case Success(:final data):
        emit(CouponLoaded(
          coupons: data,
          page: 0,
          totalPages: 1,
          totalElements: data.length,
          isLast: true,
        ));
      case ResultFailure(:final failure):
        emit(CouponError(failure.message));
    }
  }

  Future<void> refresh() => load(page: _page);

  /// Creates a coupon. Returns `null` on success, or an error message.
  Future<String?> create(CouponEntity draft) =>
      _mutate(() => _repository.create(draft));

  Future<String?> update(int id, CouponEntity draft) =>
      _mutate(() => _repository.update(id, draft));

  Future<String?> delete(int id) => _mutate(() => _repository.delete(id));

  /// Convenience toggle — there is no dedicated status endpoint, so flipping
  /// `isActive` is a full update.
  Future<String?> toggleStatus(CouponEntity coupon, {required bool isActive}) {
    if (coupon.id == null) return Future.value('Mã giảm giá không hợp lệ');
    return update(coupon.id!, coupon.copyWith(isActive: isActive));
  }

  /// Runs a mutating call, surfacing the busy flag, then reloads the page.
  Future<String?> _mutate(Future<Result<dynamic>> Function() action) async {
    final current = state;
    if (current is CouponLoaded) {
      emit(current.copyWith(isMutating: true));
    }
    final result = await action();
    switch (result) {
      case Success():
        await refresh();
        return null;
      case ResultFailure(:final failure):
        if (current is CouponLoaded) {
          emit(current.copyWith(isMutating: false));
        }
        return failure.message;
    }
  }
}
