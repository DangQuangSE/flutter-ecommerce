import 'dart:io';

import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';

abstract interface class ShopRepository {
  Future<Result<ShopEntity>> getShop();
  Future<Result<ShopEntity>> updateShop(ShopEntity shop);
  Future<Result<String>> uploadShopImage(File file, String type);
}
