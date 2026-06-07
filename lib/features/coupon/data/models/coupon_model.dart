import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/user_tier.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    super.id,
    required super.code,
    super.discountType,
    super.discountValue,
    super.minOrderAmount,
    super.maxDiscountAmount,
    super.requiredTier,
    super.startDate,
    super.endDate,
    super.usageLimit,
    super.usedCount,
    super.isActive,
  });

  /// Parses a backend `CouponResponse`. The primitive boolean `isActive` is
  /// serialised by Jackson under the key `active`, so we read both.
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: (json['id'] as num?)?.toInt(),
      code: json['code'] as String? ?? '',
      discountType: DiscountType.fromWire(json['discountType'] as String?),
      discountValue: _toDouble(json['discountValue']) ?? 0,
      minOrderAmount: _toDouble(json['minOrderAmount']),
      maxDiscountAmount: _toDouble(json['maxDiscountAmount']),
      requiredTier: UserTier.fromWire(json['requiredTier'] as String?),
      startDate: _toDate(json['startDate']),
      endDate: _toDate(json['endDate']),
      usageLimit: (json['usageLimit'] as num?)?.toInt(),
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      isActive: json['active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  /// Builds a `CouponRequest` body for create/update. Optional fields are
  /// omitted when null so the backend keeps its defaults. The active flag is
  /// sent under both `isActive` and `active` to be robust to Jackson's
  /// primitive-boolean property naming.
  Map<String, dynamic> toRequestJson() {
    return {
      'code': code,
      'discountType': discountType.wireName,
      'discountValue': discountValue,
      if (minOrderAmount != null) 'minOrderAmount': minOrderAmount,
      if (maxDiscountAmount != null) 'maxDiscountAmount': maxDiscountAmount,
      if (requiredTier != null) 'requiredTier': requiredTier!.wireName,
      if (startDate != null) 'startDate': _fmtDateTime(startDate!),
      if (endDate != null) 'endDate': _fmtDateTime(endDate!),
      if (usageLimit != null) 'usageLimit': usageLimit,
      'isActive': isActive,
      'active': isActive,
    };
  }

  factory CouponModel.fromEntity(CouponEntity e) => CouponModel(
        id: e.id,
        code: e.code,
        discountType: e.discountType,
        discountValue: e.discountValue,
        minOrderAmount: e.minOrderAmount,
        maxDiscountAmount: e.maxDiscountAmount,
        requiredTier: e.requiredTier,
        startDate: e.startDate,
        endDate: e.endDate,
        usageLimit: e.usageLimit,
        usedCount: e.usedCount,
        isActive: e.isActive,
      );

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _toDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  /// Formats as `yyyy-MM-ddTHH:mm:ss` — the shape Spring's `LocalDateTime`
  /// deserialiser accepts (no timezone suffix, no fractional seconds).
  static String _fmtDateTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final year = d.year.toString().padLeft(4, '0');
    return '$year-${two(d.month)}-${two(d.day)}'
        'T${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}
