# Result<T> Patterns

The project uses a native Dart 3 sealed `Result<T>` type instead of `dartz`.

## Definition (do not change)

```dart
// lib/core/errors/result.dart
import 'package:flutter_ecommerce/core/errors/failures.dart' as failures;

sealed class Result<T> { const Result(); }

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Named ResultFailure (not Failure) to avoid collision with failures.Failure
final class ResultFailure<T> extends Result<T> {
  final failures.Failure failure;
  const ResultFailure(this.failure);
}
```

## Returning Results

```dart
// ✅ From repository — always catch AppException subtypes
Future<Result<UserEntity>> login({required String email, required String password}) async {
  try {
    final user = await _remoteDataSource.login(email: email, password: password);
    return Success(user);
  } on UnauthorisedException catch (e) {
    return ResultFailure(AuthFailure(e.message));
  } on NetworkException catch (e) {
    return ResultFailure(NetworkFailure(e.message));
  } on AppException catch (e) {
    return ResultFailure(NetworkFailure(e.message));
  }
}

// ✅ Void success
Future<Result<void>> logout() async {
  try {
    await _remoteDataSource.logout();
    return const Success(null);
  } on AppException catch (e) {
    return ResultFailure(NetworkFailure(e.message));
  }
}
```

## Consuming Results (in BLoC)

```dart
// ✅ Exhaustive switch — no default arm needed on sealed class
final result = await _loginUseCase(email: event.email, password: event.password);
switch (result) {
  case Success(:final data):
    emit(AuthAuthenticated(data));
  case ResultFailure(:final failure):
    emit(AuthError(failure.message));
}

// ✅ Pattern match with null data (nullable success)
final result = await _repository.getCurrentUser();
switch (result) {
  case Success(:final data):
    if (data != null) {
      emit(AuthAuthenticated(data));
    } else {
      emit(const AuthUnauthenticated());
    }
  case ResultFailure():
    emit(const AuthUnauthenticated());
}
```

## Failure Types

```dart
// All defined in lib/core/errors/failures.dart
sealed class Failure extends Equatable { ... }

final class NetworkFailure extends Failure { ... }   // HTTP/connection errors
final class AuthFailure extends Failure { ... }       // 401/403
final class ParseFailure extends Failure { ... }      // JSON parse errors
final class CacheFailure extends Failure { ... }      // local storage errors
final class DomainFailure extends Failure { ... }     // business rule violations
```

## Exception Types (Data Layer Only)

```dart
// All defined in lib/core/errors/exceptions.dart
sealed class AppException implements Exception { ... }

final class NetworkException extends AppException { ... }
final class UnauthorisedException extends AppException { ... }
final class ServerException extends AppException { ... }
final class ParseException extends AppException { ... }
final class CacheException extends AppException { ... }
```

Datasources throw `AppException` subtypes.
Repositories catch them and return `ResultFailure(FailureType(...))`.
