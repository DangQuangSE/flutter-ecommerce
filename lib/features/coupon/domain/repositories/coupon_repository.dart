import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_page.dart';

/// Admin coupon operations. The backend exposes only paginated list + CRUD
/// (`/api/v1/admin/coupons`); there is no server-side search or status-toggle
/// endpoint, so toggling `isActive` is done through [update].
abstract interface class CouponRepository {
  Future<Result<CouponPage>> getCoupons({int page, int size});

  Future<Result<CouponEntity>> create(CouponEntity coupon);

  Future<Result<CouponEntity>> update(int id, CouponEntity coupon);

  Future<Result<void>> delete(int id);
}
