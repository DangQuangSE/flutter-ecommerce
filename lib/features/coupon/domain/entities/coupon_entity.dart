import 'package:equatable/equatable.dart';

import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/user_tier.dart';

/// A discount coupon managed in the admin area.
///
/// Maps to the backend `CouponResponse` / `CouponRequest`. Monetary fields use
/// [double] for display convenience (backend stores `BigDecimal`). [usedCount]
/// is read-only (server-managed). [requiredTier] / [usageLimit] / dates are
/// optional — `null` means "no requirement / no limit / unbounded".
class CouponEntity extends Equatable {
  final int? id;
  final String code;
  final DiscountType discountType;
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final UserTier? requiredTier;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;

  const CouponEntity({
    this.id,
    required this.code,
    this.discountType = DiscountType.percentage,
    this.discountValue = 0,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.requiredTier,
    this.startDate,
    this.endDate,
    this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
  });

  /// `true` when the coupon's validity window has elapsed.
  bool get isExpired {
    final end = endDate;
    return end != null && end.isBefore(DateTime.now());
  }

  /// `true` when [usageLimit] is set and fully consumed.
  bool get isUsedUp {
    final limit = usageLimit;
    return limit != null && limit > 0 && usedCount >= limit;
  }

  CouponEntity copyWith({
    int? id,
    String? code,
    DiscountType? discountType,
    double? discountValue,
    double? minOrderAmount,
    double? maxDiscountAmount,
    UserTier? requiredTier,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
  }) {
    return CouponEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      requiredTier: requiredTier ?? this.requiredTier,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        discountType,
        discountValue,
        minOrderAmount,
        maxDiscountAmount,
        requiredTier,
        startDate,
        endDate,
        usageLimit,
        usedCount,
        isActive,
      ];
}
