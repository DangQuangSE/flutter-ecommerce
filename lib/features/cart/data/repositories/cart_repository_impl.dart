import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  const CartRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<CartItemEntity>>> getCartItems() async {
    try {
      final items = await _remoteDataSource.getCart();
      return Success(items);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<List<CartItemEntity>>> addOrUpdateItem({
    required int variantId,
    required int quantity,
    bool isReplace = false,
    int? customDesignId,
  }) async {
    try {
      final items = await _remoteDataSource.addOrUpdateItem(
        variantId: variantId,
        quantity: quantity,
        isReplace: isReplace,
        customDesignId: customDesignId,
      );
      return Success(items);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<List<CartItemEntity>>> removeItem(int itemId) async {
    try {
      final items = await _remoteDataSource.removeItem(itemId);
      return Success(items);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }
}
