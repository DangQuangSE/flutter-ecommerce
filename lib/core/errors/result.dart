import 'package:flutter_ecommerce/core/errors/failures.dart' as failures;

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Named ResultFailure (not Failure) to avoid collision with failures.Failure.
final class ResultFailure<T> extends Result<T> {
  final failures.Failure failure;
  const ResultFailure(this.failure);
}
