import 'package:equatable/equatable.dart';

class ForgotPasswordResetExtra extends Equatable {
  final String email;
  final String forgotPasswordToken;

  const ForgotPasswordResetExtra({
    required this.email,
    required this.forgotPasswordToken,
  });

  @override
  List<Object?> get props => [email, forgotPasswordToken];

  @override
  String toString() =>
      'ForgotPasswordResetExtra(email: $email, forgotPasswordToken: ***)';
}
