import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/product_color_remote_datasource.dart';
import 'package:flutter_ecommerce/features/color/data/models/product_color_model.dart';

class ProductColorRemoteDataSourceImpl implements ProductColorRemoteDataSource {
  final DioClient _dioClient;

  const ProductColorRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductColorModel>> getColors() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.colors,
    );

    final list = response.data?['data'] as List?;
    if (list == null) return [];

    return list
        .map((json) => ProductColorModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductColorModel> createColor(ProductColorModel color) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.adminColors,
      data: color.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return ProductColorModel.fromJson(data);
  }

  @override
  Future<ProductColorModel> updateColor(int id, ProductColorModel color) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>(
      '${ApiConstants.adminColors}/$id',
      data: color.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return ProductColorModel.fromJson(data);
  }

  @override
  Future<void> deleteColor(int id) async {
    await _dioClient.dio.delete<void>('${ApiConstants.adminColors}/$id');
  }
}
