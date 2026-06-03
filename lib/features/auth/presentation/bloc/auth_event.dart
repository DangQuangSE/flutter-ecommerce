import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final class AuthOtpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthOtpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

final class AuthOtpVerifyRequested extends AuthEvent {
  final String email;
  final String otp;
  final String password;
  final String name;

  const AuthOtpVerifyRequested({
    required this.email,
    required this.otp,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, otp, password, name];
}

final class AuthResendOtpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthResendOtpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
