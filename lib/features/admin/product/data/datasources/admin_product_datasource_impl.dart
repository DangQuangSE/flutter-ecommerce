import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/admin_product_detail_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/admin_product_list_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_create_request_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_update_request_model.dart';

class AdminProductDatasourceImpl implements AdminProductDatasource {
  final DioClient _dioClient;

  AdminProductDatasourceImpl(this._dioClient);

  @override
  Future<PagedResponse<AdminProductListModel>> getProducts({
    String? keyword,
    int? categoryId,
    int? brandId,
    String? gender,
    String? status,
    bool? isFeatured,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'size': size};
      if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
      if (categoryId != null) params['categoryId'] = categoryId;
      if (brandId != null) params['brandId'] = brandId;
      if (gender != null) params['gender'] = gender;
      if (status != null) params['status'] = status;
      if (isFeatured != null) params['isFeatured'] = isFeatured;

      final response = await _dioClient.dio.get(
        ApiConstants.adminProducts,
        queryParameters: params,
      );
      final responseMap = response.data as Map<String, dynamic>;
      final dataMap = responseMap['data'] as Map<String, dynamic>;
      return PagedResponse.fromJson(
        dataMap,
        AdminProductListModel.fromJson,
      );
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AdminProductDetailModel> getProductById(int id) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.adminProductById(id));
      final responseMap = response.data as Map<String, dynamic>;
      return AdminProductDetailModel.fromJson(
          responseMap['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AdminProductDetailModel> createProduct(
      ProductCreateRequestModel request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.adminProducts,
        data: request.toJson(),
      );
      final responseMap = response.data as Map<String, dynamic>;
      return AdminProductDetailModel.fromJson(
          responseMap['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AdminProductDetailModel> updateProduct(
      int id, ProductUpdateRequestModel request) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.adminProductById(id),
        data: request.toJson(),
      );
      final responseMap = response.data as Map<String, dynamic>;
      return AdminProductDetailModel.fromJson(
          responseMap['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _dioClient.dio.delete(ApiConstants.adminProductById(id));
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
