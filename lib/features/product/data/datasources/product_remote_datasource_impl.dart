import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_catalog_model.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_model.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;
  final List<ProductModel> _inMemoryProducts = [];

  ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.products,
        queryParameters: {
          'page': page - 1, // Spring Pageable is 0-indexed
          'size': limit,
        },
      );
      final responseMap = response.data as Map<String, dynamic>;
      final dataMap = responseMap['data'] as Map<String, dynamic>;
      final contentList = dataMap['content'] as List;
      return contentList
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.products}/$id');
      final responseMap = response.data as Map<String, dynamic>;
      final dataMap = responseMap['data'] as Map<String, dynamic>;
      return ProductModel.fromJson(dataMap);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _inMemoryProducts.add(product);
    return product;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _inMemoryProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _inMemoryProducts[index] = product;
      return product;
    }
    throw Exception('Sản phẩm không tồn tại');
  }

  @override
  Future<bool> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final countBefore = _inMemoryProducts.length;
    _inMemoryProducts.removeWhere((p) => p.id == id);
    return _inMemoryProducts.length < countBefore;
  }

  @override
  Future<PagedResponse<ProductCatalogModel>> getCatalogProducts({
    int page = 0,
    int size = 12,
    String? keyword,
    int? categoryId,
    int? brandId,
    String? gender,
    String? productSize,
    String? color,
    double? minPrice,
    double? maxPrice,
    String sort = 'id,desc',
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'size': size,
        'sort': sort
      };
      if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
      if (categoryId != null) params['categoryId'] = categoryId;
      if (brandId != null) params['brandId'] = brandId;
      if (gender != null) params['gender'] = gender;
      if (productSize != null) params['productSize'] = productSize;
      if (color != null) params['color'] = color;
      if (minPrice != null) params['minPrice'] = minPrice;
      if (maxPrice != null) params['maxPrice'] = maxPrice;

      final response = await _dioClient.dio.get(
        ApiConstants.products,
        queryParameters: params,
      );
      final dataMap = response.data['data'] as Map<String, dynamic>;
      return PagedResponse.fromJson(
        dataMap,
        ProductCatalogModel.fromJson,
      );
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
