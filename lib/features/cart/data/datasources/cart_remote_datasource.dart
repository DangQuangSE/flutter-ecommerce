import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

/// Contract for the cart remote data source.
abstract interface class CartRemoteDataSource {
  /// GET /api/carts/me
  Future<List<CartItemEntity>> getCart();

  /// POST /api/carts/me/items
  Future<List<CartItemEntity>> addOrUpdateItem({
    required int variantId,
    required int quantity,
    bool isReplace = false,
    int? customDesignId,
  });

  /// DELETE /api/carts/me/items/{itemId}
  Future<List<CartItemEntity>> removeItem(int itemId);
}
