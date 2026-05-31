sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

final class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode});
}

final class ParseException extends AppException {
  const ParseException(super.message);
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class UnauthorisedException extends AppException {
  const UnauthorisedException(super.message);
}

final class ServerException extends AppException {
  final int statusCode;
  const ServerException(super.message, {required this.statusCode});
}
