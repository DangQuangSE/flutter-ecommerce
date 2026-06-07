import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';

sealed class CouponState extends Equatable {
  const CouponState();

  @override
  List<Object?> get props => [];
}

final class CouponInitial extends CouponState {
  const CouponInitial();
}

final class CouponLoading extends CouponState {
  const CouponLoading();
}

final class CouponLoaded extends CouponState {
  final List<CouponEntity> coupons;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  /// True while a create/update/delete round-trip is in flight, so the UI can
  /// show a subtle busy indicator without dropping the current list.
  final bool isMutating;

  const CouponLoaded({
    required this.coupons,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
    this.isMutating = false,
  });

  CouponLoaded copyWith({
    List<CouponEntity>? coupons,
    int? page,
    int? totalPages,
    int? totalElements,
    bool? isLast,
    bool? isMutating,
  }) {
    return CouponLoaded(
      coupons: coupons ?? this.coupons,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      isLast: isLast ?? this.isLast,
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props =>
      [coupons, page, totalPages, totalElements, isLast, isMutating];
}

final class CouponError extends CouponState {
  final String message;
  const CouponError(this.message);

  @override
  List<Object?> get props => [message];
}
