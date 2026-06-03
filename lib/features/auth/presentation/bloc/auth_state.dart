import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthOtpSent extends AuthState {
  final String email;
  final String password;
  final String name;

  const AuthOtpSent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];

  @override
  String toString() =>
      'AuthOtpSent(email: $email, password: ***, name: $name)';
}

final class AuthRegistrationSuccess extends AuthState {
  final String? welcomeName;

  const AuthRegistrationSuccess({this.welcomeName});

  @override
  List<Object?> get props => [welcomeName];
}

final class AuthRegisterAccountExists extends AuthState {
  final String message;

  const AuthRegisterAccountExists(this.message);

  @override
  List<Object?> get props => [message];
}

final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
