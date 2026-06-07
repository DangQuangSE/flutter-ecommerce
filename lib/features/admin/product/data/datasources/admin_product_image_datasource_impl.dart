import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/admin/product/data/datasources/admin_product_image_datasource.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_image_model.dart';

class AdminProductImageDatasourceImpl implements AdminProductImageDatasource {
  final DioClient _dioClient;

  AdminProductImageDatasourceImpl(this._dioClient);

  @override
  Future<ProductImageModel> addImage(
    int productId,
    String filePath,
    String fileName, {
    bool isThumbnail = false,
    int sortOrder = 0,
    int? variantId,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'isThumbnail': isThumbnail,
        'sortOrder': sortOrder,
        if (variantId != null) 'variantId': variantId,
      });
      final response = await _dioClient.dio.post(
        ApiConstants.adminProductImages(productId),
        data: formData,
        onSendProgress: onSendProgress,
      );
      final responseMap = response.data as Map<String, dynamic>;
      return ProductImageModel.fromJson(responseMap['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteImage(int imageId) async {
    try {
      await _dioClient.dio.delete(ApiConstants.adminImageById(imageId));
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
