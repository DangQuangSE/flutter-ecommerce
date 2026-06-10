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

  const AuthOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

final class AuthOtpVerifyRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthOtpVerifyRequested({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

final class AuthResendOtpRequested extends AuthEvent {
  final String email;

  const AuthResendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

final class AuthRegisterPasswordSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterPasswordSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
