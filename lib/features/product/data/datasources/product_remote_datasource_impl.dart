import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_model.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;
  
  static final List<ProductModel> _inMemoryProducts = [];

  const ProductRemoteDataSourceImpl(this._dioClient);

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
        e.response?.data?['message'] as String? ?? e.message ?? 'Lỗi kết nối mạng',
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
        e.response?.data?['message'] as String? ?? e.message ?? 'Lỗi kết nối mạng',
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
}
