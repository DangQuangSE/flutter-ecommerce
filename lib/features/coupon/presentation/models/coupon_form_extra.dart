import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';

class CouponFormExtra {
  final CouponCubit cubit;
  final CouponEntity? coupon;

  const CouponFormExtra({
    required this.cubit,
    this.coupon,
  });
}
