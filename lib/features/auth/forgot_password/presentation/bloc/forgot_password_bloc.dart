import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/usecases/forgot_password_request_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/usecases/forgot_password_reset_usecase.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/usecases/forgot_password_verify_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_event.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_state.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/utils/forgot_password_error_messages.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordRequestOtpUseCase _requestOtpUseCase;
  final ForgotPasswordVerifyOtpUseCase _verifyOtpUseCase;
  final ForgotPasswordResetUseCase _resetUseCase;

  ForgotPasswordBloc({
    required ForgotPasswordRequestOtpUseCase requestOtpUseCase,
    required ForgotPasswordVerifyOtpUseCase verifyOtpUseCase,
    required ForgotPasswordResetUseCase resetUseCase,
  })  : _requestOtpUseCase = requestOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _resetUseCase = resetUseCase,
        super(const ForgotPasswordInitial()) {
    on<ForgotPasswordEmailSubmitted>(_onEmailSubmitted);
    on<ForgotPasswordOtpSubmitted>(_onOtpSubmitted);
    on<ForgotPasswordResendRequested>(_onResendRequested);
    on<ForgotPasswordResetSubmitted>(_onResetSubmitted);
  }

  Future<void> _onEmailSubmitted(
    ForgotPasswordEmailSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _requestOtpUseCase(email: event.email.trim());
    switch (result) {
      case Success(:final data):
        emit(ForgotPasswordOtpSent(
          email: event.email.trim(),
          neutralMessage: data,
        ));
      case ResultFailure(:final failure):
        emit(ForgotPasswordError(mapForgotPasswordRequestFailure(failure)));
    }
  }

  Future<void> _onOtpSubmitted(
    ForgotPasswordOtpSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _verifyOtpUseCase(
      email: event.email.trim(),
      otpCode: event.otpCode.trim(),
    );
    switch (result) {
      case Success(:final data):
        emit(ForgotPasswordOtpVerified(
          email: event.email.trim(),
          forgotPasswordToken: data,
        ));
      case ResultFailure(:final failure):
        emit(ForgotPasswordError(mapForgotPasswordOtpFailure(failure)));
    }
  }

  Future<void> _onResendRequested(
    ForgotPasswordResendRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _requestOtpUseCase(email: event.email.trim());
    switch (result) {
      case Success(:final data):
        emit(ForgotPasswordResendSuccess(
          email: event.email.trim(),
          neutralMessage: data,
        ));
      case ResultFailure(:final failure):
        emit(ForgotPasswordError(mapForgotPasswordRequestFailure(failure)));
    }
  }

  Future<void> _onResetSubmitted(
    ForgotPasswordResetSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _resetUseCase(
      forgotPasswordToken: event.forgotPasswordToken,
      newPassword: event.newPassword,
    );
    switch (result) {
      case Success():
        emit(const ForgotPasswordResetSuccess());
      case ResultFailure(:final failure):
        emit(ForgotPasswordError(mapForgotPasswordResetFailure(failure)));
    }
  }
}
