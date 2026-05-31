import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

final class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

final class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

final class DomainFailure extends Failure {
  const DomainFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
