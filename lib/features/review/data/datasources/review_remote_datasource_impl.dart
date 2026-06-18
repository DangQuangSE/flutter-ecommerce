import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/review/data/datasources/review_remote_datasource.dart';
import 'package:flutter_ecommerce/features/review/data/models/review_model.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_page.dart';

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
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ReviewPage> getAllReviews({int page = 0, int size = 10}) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        ApiConstants.adminReviews,
        queryParameters: {'page': page, 'size': size, 'sort': 'createdAt,desc'},
      );
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw const ParseException('Phản hồi danh sách đánh giá không hợp lệ');
      }
      final content = (data['content'] as List<dynamic>? ?? [])
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ReviewPage(
        items: content,
        page: (data['number'] as num?)?.toInt() ?? page,
        totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
        totalElements:
            (data['totalElements'] as num?)?.toInt() ?? content.length,
        isLast: data['last'] as bool? ?? true,
      );
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ReviewModel> replyToReview(int reviewId, String reply) async {
    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        ApiConstants.adminReviewReply(reviewId),
        data: jsonEncode(reply),
      );
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw const ParseException('Phản hồi đánh giá không hợp lệ');
      }
      return ReviewModel.fromJson(data);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi kết nối mạng',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ReviewModel> createReview({
    required int orderItemId,
    required int rating,
    required String comment,
    List<String> imagePaths = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'review': MultipartFile.fromString(
          jsonEncode({
            'orderItemId': orderItemId,
            'rating': rating,
            'comment': comment,
          }),
          contentType: MediaType('application', 'json'),
        ),
        if (imagePaths.isNotEmpty)
          'images': await Future.wait(imagePaths.map(
            (path) =>
                MultipartFile.fromFile(path, filename: path.split('/').last),
          )),
      });

      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        ApiConstants.userReviews,
        data: formData,
      );
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw const ParseException('Phản hồi gửi đánh giá không hợp lệ');
      }
      return ReviewModel.fromJson(data);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            'Lỗi gửi đánh giá',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
