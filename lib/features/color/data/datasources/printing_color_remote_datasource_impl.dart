import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/printing_color_remote_datasource.dart';
import 'package:flutter_ecommerce/features/color/data/models/printing_color_model.dart';

class PrintingColorRemoteDataSourceImpl implements PrintingColorRemoteDataSource {
  final DioClient _dioClient;

  const PrintingColorRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PrintingColorModel>> getColors() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.adminPrintingColors,
    );

    final list = response.data?['data'] as List?;
    if (list == null) return [];

    return list
        .map((json) => PrintingColorModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PrintingColorModel> createColor(PrintingColorModel color) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.adminPrintingColors,
      data: color.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return PrintingColorModel.fromJson(data);
  }

  @override
  Future<PrintingColorModel> updateColor(int id, PrintingColorModel color) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>(
      '${ApiConstants.adminPrintingColors}/$id',
      data: color.toJson(),
    );

    final data = response.data?['data'] as Map<String, dynamic>;
    return PrintingColorModel.fromJson(data);
  }

  @override
  Future<void> deleteColor(int id) async {
    await _dioClient.dio.delete<void>('${ApiConstants.adminPrintingColors}/$id');
  }
}
