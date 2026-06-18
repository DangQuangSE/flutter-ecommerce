import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_variant_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_variant_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_variant_request_model.dart';

class AdminProductVariantDatasourceImpl
    implements AdminProductVariantDatasource {
  final DioClient _dioClient;

  AdminProductVariantDatasourceImpl(this._dioClient);

  Never _throwNetworkException(DioException e) => throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );

  @override
  Future<ProductVariantModel> createVariant(
      int productId, ProductVariantRequestModel request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.adminProductVariants(productId),
        data: request.toJson(),
      );
      final responseMap = response.data as Map<String, dynamic>;
      return ProductVariantModel.fromJson(
          responseMap['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwNetworkException(e);
    }
  }

  @override
  Future<List<ProductVariantModel>> createVariantsBatch(
      int productId, List<ProductVariantRequestModel> requests) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.adminProductVariantsBatch(productId),
        data: requests.map((r) => r.toJson()).toList(),
      );
      final responseMap = response.data as Map<String, dynamic>;
      final data = responseMap['data'] as List<dynamic>;
      return data
          .map((item) =>
              ProductVariantModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwNetworkException(e);
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
      return ProductVariantModel.fromJson(
          responseMap['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwNetworkException(e);
    }
  }

  @override
  Future<void> deleteVariant(int variantId) async {
    try {
      await _dioClient.dio.delete(ApiConstants.adminVariantById(variantId));
    } on DioException catch (e) {
      _throwNetworkException(e);
    }
  }
}
