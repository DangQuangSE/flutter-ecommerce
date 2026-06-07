import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';

/// A page of coupons from the paginated admin list endpoint
/// (`GET /api/v1/admin/coupons`).
class CouponPage extends Equatable {
  final List<CouponEntity> items;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  const CouponPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });

  @override
  List<Object?> get props => [items, page, totalPages, totalElements, isLast];
}
