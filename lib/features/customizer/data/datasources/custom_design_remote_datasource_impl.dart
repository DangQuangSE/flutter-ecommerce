import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/customizer/data/datasources/custom_design_remote_datasource.dart';
import 'package:flutter_ecommerce/features/customizer/data/models/printing_config_model.dart';

import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';

class CustomDesignRemoteDataSourceImpl implements CustomDesignRemoteDataSource {
  final DioClient _dioClient;

  CustomDesignRemoteDataSourceImpl(this._dioClient);

  @override
  Future<int> saveDesign({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required String backMetadata,
    required Uint8List imageBytes,
    Uint8List? backImageBytes,
  }) async {
    try {
      final formDataMap = <String, dynamic>{
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: 'design_front.png',
          contentType: MediaType('image', 'png'),
        ),
        'data': MultipartFile.fromString(
          jsonEncode({
            'materialId': materialId,
            'numTextLines': numTextLines,
            'numImages': numImages,
            'metadata': metadata,
            'backMetadata': backMetadata,
          }),
          contentType: MediaType('application', 'json'),
        ),
      };
      if (backImageBytes != null) {
        formDataMap['backFile'] = MultipartFile.fromBytes(
          backImageBytes,
          filename: 'design_back.png',
          contentType: MediaType('image', 'png'),
        );
      }
      final formData = FormData.fromMap(formDataMap);

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
  Future<
      ({
        String? designImageUrl,
        String? backDesignImageUrl,
        String designMetadata,
        String backDesignMetadata,
        String printingMaterialName,
        int? printingMaterialId,
        int numTextLines,
        int numImages,
        double totalPrintingPrice,
      })> getExistingDesign(int id, {DesignViewerRole role = DesignViewerRole.customer}) async {
    try {
      final path = role == DesignViewerRole.admin
          ? ApiConstants.adminCustomDesignById(id)
          : ApiConstants.customDesignById(id);
      final response = await _dioClient.dio.get(path);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return (
        designImageUrl: data['designImageUrl'] as String?,
        backDesignImageUrl: data['backDesignImageUrl'] as String?,
        designMetadata: data['designMetadata'] as String? ?? '',
        backDesignMetadata:
            data['backDesignMetadata'] as String? ?? '',
        printingMaterialName:
            data['printingMaterialName'] as String? ?? 'In chuyển nhiệt',
        printingMaterialId: (data['printingMaterialId'] as num?)?.toInt(),
        numTextLines: (data['numTextLines'] as num? ?? 0).toInt(),
        numImages: (data['numImages'] as num? ?? 0).toInt(),
        totalPrintingPrice:
            (data['totalPrintingPrice'] as num? ?? 0.0).toDouble(),
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
      return PrintingConfigModel.fromJson(data).toEntity();
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
