import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_model.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  // ignore: unused_field — used when stub is replaced with real Dio calls
  final DioClient _dioClient;
  
  static final List<ProductModel> _inMemoryProducts = List.from(ProductModel.mockList);

  const ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _inMemoryProducts;
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _inMemoryProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => _inMemoryProducts.first,
    );
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
