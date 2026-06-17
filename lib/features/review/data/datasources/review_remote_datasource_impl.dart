import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/review/data/datasources/review_remote_datasource.dart';
import 'package:flutter_ecommerce/features/review/data/models/review_model.dart';

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient _dioClient;

  const ReviewRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ReviewModel>> getProductReviews(
    int productId, {
    int page = 0,
    int size = 5,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.productReviews(productId),
        queryParameters: {'page': page, 'size': size, 'sort': 'createdAt,desc'},
      );
      final dataMap = response.data['data'] as Map<String, dynamic>;
      final contentList = dataMap['content'] as List;
      return contentList
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
