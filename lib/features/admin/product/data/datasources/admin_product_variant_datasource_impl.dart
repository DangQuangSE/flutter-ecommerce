import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_variant_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_variant_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_variant_request_model.dart';

class AdminProductVariantDatasourceImpl implements AdminProductVariantDatasource {
  final DioClient _dioClient;

  AdminProductVariantDatasourceImpl(this._dioClient);

  @override
  Future<ProductVariantModel> createVariant(
      int productId, ProductVariantRequestModel request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.adminProductVariants(productId),
        data: request.toJson(),
      );
      final responseMap = response.data as Map<String, dynamic>;
      return ProductVariantModel.fromJson(responseMap['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ProductVariantModel> updateVariant(
      int variantId, ProductVariantRequestModel request) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.adminVariantById(variantId),
        data: request.toJson(),
      );
      final responseMap = response.data as Map<String, dynamic>;
      return ProductVariantModel.fromJson(responseMap['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteVariant(int variantId) async {
    try {
      await _dioClient.dio.delete(ApiConstants.adminVariantById(variantId));
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
