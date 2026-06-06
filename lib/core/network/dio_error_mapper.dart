import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';

String? extractApiMessage(dynamic data) {
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
  }
  return null;
}

Failure failureFromDioException(DioException exception) {
  final embedded = exception.error;
  if (embedded is UnauthorisedException) {
    return AuthFailure(embedded.message);
  }
  if (embedded is ServerException) {
    return NetworkFailure(
      embedded.message,
      statusCode: embedded.statusCode,
    );
  }
  if (embedded is NetworkException) {
    return NetworkFailure(
      embedded.message,
      statusCode: embedded.statusCode,
    );
  }
  if (embedded is AppException) {
    return NetworkFailure(embedded.message);
  }

  final response = exception.response;
  final statusCode = response?.statusCode;
  final message = extractApiMessage(response?.data) ??
      exception.message ??
      'Unexpected error';

  return NetworkFailure(message, statusCode: statusCode);
}
