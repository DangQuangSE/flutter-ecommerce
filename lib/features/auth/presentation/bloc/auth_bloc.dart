import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // ignore: unused_field — reserved for real login wiring
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
    await Future.delayed(const Duration(milliseconds: 500));

    final String email = event.email.trim().toLowerCase();
    final bool isAdminLogin =
        (email == 'admin' || email == 'admin@sportpro.com') &&
            event.password == 'admin';

    final mockUser = UserEntity(
      id: isAdminLogin ? 'mock-admin' : 'mock-u-001',
      email: isAdminLogin
          ? 'admin@sportpro.com'
          : (event.email.isEmpty ? 'demo@sportpro.com' : event.email),
      name: isAdminLogin ? 'Admin Sport Pro' : 'VĐV Sport Pro',
      avatarUrl: isAdminLogin
          ? 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e'
          : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      createdAt: DateTime.now(),
    );

    emit(AuthAuthenticated(mockUser));
  }

  Future<void> _onOtpRequested(
    AuthOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _requestOtpUseCase(email: event.email.trim());
    switch (result) {
      case Success():
        emit(AuthOtpSent(
          email: event.email.trim(),
          password: event.password,
          name: event.name.trim(),
        ));
      case ResultFailure(:final failure):
        emit(AuthError(_failureMessage(failure)));
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
        emit(AuthError(_failureMessage(failure)));
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
        emit(AuthRegistrationSuccess(
          welcomeName: event.name.trim().isEmpty ? null : event.name.trim(),
        ));
      case ResultFailure(:final failure):
        if (failure is NetworkFailure && failure.statusCode == 409) {
          emit(AuthRegisterAccountExists(_failureMessage(failure)));
        } else {
          emit(AuthError(_failureMessage(failure)));
        }
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
          name: event.name.trim(),
        ));
      case ResultFailure(:final failure):
        emit(AuthError(_failureMessage(failure)));
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

  String _failureMessage(Failure failure) => failure.message;
}
