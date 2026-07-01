import 'dart:io';

import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:flutter_ecommerce/features/shop/data/models/shop_model.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource _remoteDataSource;

  const ShopRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<ShopEntity>> getShop() {
    return _guard(() => _remoteDataSource.getShop());
  }

  @override
  Future<Result<ShopEntity>> updateShop(ShopEntity shop) {
    return _guard(
      () => _remoteDataSource.updateShop(ShopModel.fromEntity(shop)),
    );
  }

  @override
  Future<Result<String>> uploadShopImage(File file, String type) {
    return _guard(() => _remoteDataSource.uploadShopImage(file, type));
  }

  /// Maps known [AppException] subtypes to the corresponding [Failure].
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
