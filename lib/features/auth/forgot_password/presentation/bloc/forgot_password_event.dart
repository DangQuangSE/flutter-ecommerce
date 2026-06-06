import 'package:equatable/equatable.dart';

sealed class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

final class ForgotPasswordEmailSubmitted extends ForgotPasswordEvent {
  final String email;

  const ForgotPasswordEmailSubmitted({required this.email});

  @override
  List<Object?> get props => [email];
}

final class ForgotPasswordOtpSubmitted extends ForgotPasswordEvent {
  final String email;
  final String otpCode;

  const ForgotPasswordOtpSubmitted({
    required this.email,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [email, otpCode];
}

final class ForgotPasswordResendRequested extends ForgotPasswordEvent {
  final String email;

  const ForgotPasswordResendRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

final class ForgotPasswordResetSubmitted extends ForgotPasswordEvent {
  final String forgotPasswordToken;
  final String newPassword;

  const ForgotPasswordResetSubmitted({
    required this.forgotPasswordToken,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [forgotPasswordToken, newPassword];

  @override
  String toString() =>
      'ForgotPasswordResetSubmitted(forgotPasswordToken: ***, newPassword: ***)';
}
