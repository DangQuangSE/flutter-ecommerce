import 'package:equatable/equatable.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

final class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

final class ForgotPasswordOtpSent extends ForgotPasswordState {
  final String email;
  final String neutralMessage;

  const ForgotPasswordOtpSent({
    required this.email,
    required this.neutralMessage,
  });

  @override
  List<Object?> get props => [email, neutralMessage];
}

final class ForgotPasswordOtpVerified extends ForgotPasswordState {
  final String email;
  final String forgotPasswordToken;

  const ForgotPasswordOtpVerified({
    required this.email,
    required this.forgotPasswordToken,
  });

  @override
  List<Object?> get props => [email, forgotPasswordToken];

  @override
  String toString() =>
      'ForgotPasswordOtpVerified(email: $email, forgotPasswordToken: ***)';
}

final class ForgotPasswordResendSuccess extends ForgotPasswordState {
  final String email;
  final String neutralMessage;

  const ForgotPasswordResendSuccess({
    required this.email,
    required this.neutralMessage,
  });

  @override
  List<Object?> get props => [email, neutralMessage];
}

final class ForgotPasswordResetSuccess extends ForgotPasswordState {
  const ForgotPasswordResetSuccess();
}

final class ForgotPasswordError extends ForgotPasswordState {
  final String message;

  const ForgotPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
