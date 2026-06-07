import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:flutter_ecommerce/features/cart/data/models/cart_response_model.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient _dioClient;

  const CartRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CartItemEntity>> getCart() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.cart);
      final responseMap = response.data as Map<String, dynamic>;
      final dataMap = responseMap['data'] as Map<String, dynamic>;
      final cartResponse = CartResponseModel.fromJson(dataMap);
      return cartResponse.items;
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<CartItemEntity>> addOrUpdateItem({
    required int variantId,
    required int quantity,
    bool isReplace = false,
    int? customDesignId,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.cart}/items',
        data: {
          'variantId': variantId,
          'quantity': quantity,
          'isReplace': isReplace,
          if (customDesignId != null) 'customDesignId': customDesignId,
        },
      );
      final responseMap = response.data as Map<String, dynamic>;
      final dataMap = responseMap['data'] as Map<String, dynamic>;
      final cartResponse = CartResponseModel.fromJson(dataMap);
      return cartResponse.items;
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<CartItemEntity>> removeItem(int itemId) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.cart}/items/$itemId');
      return await getCart();
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
