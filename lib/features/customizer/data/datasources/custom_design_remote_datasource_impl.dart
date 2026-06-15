import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/customizer/data/datasources/custom_design_remote_datasource.dart';

import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';

class CustomDesignRemoteDataSourceImpl implements CustomDesignRemoteDataSource {
  final DioClient _dioClient;

  CustomDesignRemoteDataSourceImpl(this._dioClient);

  @override
  Future<int> saveDesign({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required Uint8List imageBytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: 'design.png',
          contentType: MediaType('image', 'png'),
        ),
        'data': MultipartFile.fromString(
          jsonEncode({
            'materialId': materialId,
            'numTextLines': numTextLines,
            'numImages': numImages,
            'metadata': metadata,
          }),
          contentType: MediaType('application', 'json'),
        ),
      });

      final response = await _dioClient.dio.post(
        ApiConstants.customDesigns,
        data: formData,
      );

      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return (data['id'] as num).toInt();
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi upload thiết kế',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<({String designMetadata, String printingMaterialName})>
      getExistingDesign(int id) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.customDesignById(id));
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return (
        designMetadata: data['designMetadata'] as String? ?? '',
        printingMaterialName:
            data['printingMaterialName'] as String? ?? 'In chuyển nhiệt',
      );
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi tải thiết kế hiện có',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PrintingConfigEntity> getPrintingConfigs() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.printingAll);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return PrintingConfigEntity.fromJson(data);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi tải cấu hình in ấn',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
