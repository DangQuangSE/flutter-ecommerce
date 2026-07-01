import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/review/data/datasources/review_remote_datasource.dart';
import 'package:flutter_ecommerce/features/review/data/models/review_model.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_page.dart';

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  static const String _reviewPart = 'review';
  static const String _imagesPart = 'images';
  static const String _orderItemIdField = 'orderItemId';
  static const String _ratingField = 'rating';
  static const String _commentField = 'comment';
  static const String _jsonMimeType = 'application';
  static const String _jsonMimeSubtype = 'json';

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
      return _parseReviewList(response.data);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            AppStrings.networkConnectionError,
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
        throw const ParseException(AppStrings.reviewListParseError);
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
            AppStrings.networkConnectionError,
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
        throw const ParseException(AppStrings.reviewParseError);
      }
      return ReviewModel.fromJson(data);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            AppStrings.networkConnectionError,
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
        _reviewPart: MultipartFile.fromString(
          jsonEncode({
            _orderItemIdField: orderItemId,
            _ratingField: rating,
            _commentField: comment,
          }),
          contentType: MediaType(_jsonMimeType, _jsonMimeSubtype),
        ),
        if (imagePaths.isNotEmpty)
          _imagesPart: await Future.wait(imagePaths.map(
            (path) =>
                MultipartFile.fromFile(path, filename: path.split('/').last),
          )),
      });

      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        ApiConstants.userReviews,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw const ParseException(AppStrings.writeReviewParseError);
      }
      return ReviewModel.fromJson(data);
    } on DioException catch (e) {
      final embedded = e.error;
      if (embedded is AppException) {
        throw NetworkException(
          embedded.message,
          statusCode: embedded is ServerException ? embedded.statusCode : null,
        );
      }
      throw NetworkException(
        e.response?.data?['message'] as String? ??
            e.message ??
            AppStrings.writeReviewSubmitError,
        statusCode: e.response?.statusCode,
      );
    }
  }

  List<ReviewModel> _parseReviewList(dynamic responseData) {
    final content = _extractReviewContent(responseData);
    if (content == null) {
      throw const ParseException(AppStrings.reviewListParseError);
    }
    return content
        .whereType<Map<String, dynamic>>()
        .map(ReviewModel.fromJson)
        .toList();
  }

  List<dynamic>? _extractReviewContent(dynamic responseData) {
    if (responseData is List<dynamic>) return responseData;
    if (responseData is! Map<String, dynamic>) return null;

    final data = responseData['data'];
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final content = data['content'] ?? data['items'];
      if (content is List<dynamic>) return content;
    }

    final content = responseData['content'] ?? responseData['items'];
    return content is List<dynamic> ? content : null;
  }
}
