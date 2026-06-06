import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/brand/data/datasources/brand_remote_datasource.dart';
import 'package:flutter_ecommerce/features/brand/data/models/brand_model.dart';

class BrandRemoteDataSourceImpl implements BrandRemoteDataSource {
  final DioClient _dioClient;

  const BrandRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<BrandModel>> getBrands({
    int page = 0,
    int size = 100,
    String? search,
  }) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.brands,
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final data = response.data?['data'];
    if (data == null) return [];

    final content = data['content'] as List?;
    if (content == null) return [];

    return content
        .map((json) => BrandModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BrandModel> createBrand(BrandModel brand) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.adminBrands,
      data: brand.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return BrandModel.fromJson(data);
  }

  @override
  Future<BrandModel> updateBrand(int id, BrandModel brand) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>(
      '${ApiConstants.adminBrands}/$id',
      data: brand.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return BrandModel.fromJson(data);
  }

  @override
  Future<void> deleteBrand(int id) async {
    await _dioClient.dio.delete<void>('${ApiConstants.adminBrands}/$id');
  }

  @override
  Future<void> updateBrandStatus(int id, bool isActive) async {
    await _dioClient.dio.patch<void>(
      '${ApiConstants.adminBrands}/$id/status',
      queryParameters: {'isActive': isActive},
    );
  }
}
