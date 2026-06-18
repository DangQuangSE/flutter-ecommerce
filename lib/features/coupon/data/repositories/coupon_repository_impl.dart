import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/coupon/data/datasources/coupon_remote_datasource.dart';
import 'package:flutter_ecommerce/features/coupon/data/models/coupon_model.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_page.dart';
import 'package:flutter_ecommerce/features/coupon/domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource _remoteDataSource;

  const CouponRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<CouponPage>> getCoupons({int page = 0, int size = 100}) {
    return _guard(() => _remoteDataSource.getCoupons(page: page, size: size));
  }

  @override
  Future<Result<CouponEntity>> create(CouponEntity coupon) {
    return _guard(
        () => _remoteDataSource.create(CouponModel.fromEntity(coupon)));
  }

  @override
  Future<Result<CouponEntity>> update(int id, CouponEntity coupon) {
    return _guard(
        () => _remoteDataSource.update(id, CouponModel.fromEntity(coupon)));
  }

  @override
  Future<Result<void>> delete(int id) {
    return _guard(() => _remoteDataSource.delete(id));
  }

  @override
  Future<Result<List<CouponEntity>>> getUserAvailableCoupons() {
    return _guard(() async {
      final models = await _remoteDataSource.getUserAvailableCoupons();
      return models;
    });
  }

  /// Runs [action], mapping known exceptions to the corresponding [Failure].
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on UnauthorisedException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
    } on ParseException catch (e) {
      return ResultFailure(ParseFailure(e.message));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }
}
