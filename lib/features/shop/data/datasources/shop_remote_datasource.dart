import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/shop/data/models/shop_model.dart';

abstract interface class ShopRemoteDataSource {
  /// Fetches the public shop profile (no auth required).
  Future<ShopModel> getShop();

  /// Updates the shop profile (ADMIN only — DioClient attaches Bearer token).
  Future<ShopModel> updateShop(ShopModel shop);

  /// Uploads a shop image to Cloudinary via the backend and returns the URL.
  Future<String> uploadShopImage(File file, String type);
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final DioClient _dioClient;

  const ShopRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ShopModel> getShop() async {
    try {
      final response = await _dioClient.dio
          .get<Map<String, dynamic>>(ApiConstants.shop);
      return _parseShop(response.data);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Không thể tải thông tin cửa hàng',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ShopModel> updateShop(ShopModel shop) async {
    try {
      final response = await _dioClient.dio.put<Map<String, dynamic>>(
        ApiConstants.adminShop,
        data: shop.toUpdateJson(),
      );
      return _parseShop(response.data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw UnauthorisedException(
          e.response?.data?['message'] as String? ?? 'Không có quyền truy cập',
        );
      }
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Không thể cập nhật thông tin cửa hàng',
        statusCode: statusCode,
      );
    }
  }

  @override
  Future<String> uploadShopImage(File file, String type) async {
    try {
      final fileName = file.uri.pathSegments.last;
      final ext = fileName.split('.').last.toLowerCase();
      final mime = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: DioMediaType.parse(mime),
        ),
        'type': type,
      });
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        ApiConstants.adminShopUploadImage,
        data: formData,
      );
      final url = response.data?['data']?['url'] as String?;
      if (url == null) throw const ParseException('URL ảnh không hợp lệ');
      return url;
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Không thể tải ảnh lên',
        statusCode: e.response?.statusCode,
      );
    }
  }

  ShopModel _parseShop(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Phản hồi thông tin cửa hàng không hợp lệ');
    }
    return ShopModel.fromJson(data);
  }
}
