import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/utils/auth_error_messages.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RequestOtpUseCase _requestOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final RegisterUseCase _registerUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RequestOtpUseCase requestOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required RegisterUseCase registerUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _requestOtpUseCase = requestOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _registerUseCase = registerUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _loginUseCase(
        email: event.email.trim(),
        password: event.password,
      );
      switch (result) {
        case Success(:final data):
          emit(AuthAuthenticated(data));
        case ResultFailure(:final failure):
          emit(AuthLoginFailed(mapLoginFailureMessage(failure)));
      }
    } catch (_) {
      emit(const AuthLoginFailed('Không thể đăng nhập. Vui lòng thử lại.'));
    }
  }

  Future<void> _onOtpRequested(
    AuthOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _requestOtpUseCase(email: event.email.trim());
      switch (result) {
        case Success():
          emit(AuthOtpSent(
            email: event.email.trim(),
            password: event.password,
          ));
        case ResultFailure(:final failure):
          _emitRegisterFailure(failure, emit);
      }
    } catch (_) {
      emit(const AuthError('Không thể đăng ký. Vui lòng thử lại.'));
    }
  }

  Future<void> _onOtpVerifyRequested(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final email = event.email.trim();

    final verifyResult = await _verifyOtpUseCase(
      email: email,
      otp: event.otp,
    );
    switch (verifyResult) {
      case ResultFailure(:final failure):
        emit(AuthError(mapRegisterOtpFailureMessage(failure)));
        return;
      case Success():
        break;
    }

    final registerResult = await _registerUseCase(
      email: email,
      password: event.password,
    );
    switch (registerResult) {
      case Success():
        emit(const AuthRegistrationSuccess());
      case ResultFailure(:final failure):
        _emitRegisterFailure(failure, emit);
    }
  }

  Future<void> _onResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _resendOtpUseCase(email: event.email.trim());
    switch (result) {
      case Success():
        emit(AuthOtpSent(
          email: event.email.trim(),
          password: event.password,
        ));
      case ResultFailure(:final failure):
        _emitRegisterFailure(failure, emit);
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.getCurrentUser();
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
  }

  void _emitRegisterFailure(Failure failure, Emitter<AuthState> emit) {
    final message = mapRegisterFailureMessage(failure);
    if (isRegisterEmailExistsFailure(failure)) {
      emit(AuthRegisterAccountExists(message));
    } else {
      emit(AuthError(message));
    }
  }

}
