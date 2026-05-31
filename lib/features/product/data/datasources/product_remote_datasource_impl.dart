import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_model.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  // ignore: unused_field — used when stub is replaced with real Dio calls
  final DioClient _dioClient;
  const ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    // TODO: replace with _dioClient.dio.get(ApiConstants.products, ...)
    await Future.delayed(const Duration(milliseconds: 500));
    return ProductModel.mockList;
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ProductModel.mockList.firstWhere(
      (p) => p.id == id,
      orElse: () => ProductModel.mockList.first,
    );
  }
}
