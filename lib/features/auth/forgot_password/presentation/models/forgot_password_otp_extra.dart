import 'package:equatable/equatable.dart';

class ForgotPasswordOtpExtra extends Equatable {
  final String email;
  final String neutralMessage;

  const ForgotPasswordOtpExtra({
    required this.email,
    required this.neutralMessage,
  });

  @override
  List<Object?> get props => [email, neutralMessage];
}
