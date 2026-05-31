import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_ecommerce/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // ignore: unused_field
  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // Simulate a short network delay for premium visual feedback (500ms)
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock user for UI demo to bypass backend connectivity issues
    final mockUser = UserEntity(
      id: 'mock-u-001',
      email: event.email.isEmpty ? 'demo@sportpro.com' : event.email,
      name: 'VĐV Sport Pro',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      createdAt: DateTime.now(),
    );
    
    emit(AuthAuthenticated(mockUser));
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // Simulate a short network delay for premium visual feedback (500ms)
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock user for UI demo to bypass backend connectivity issues
    final mockUser = UserEntity(
      id: 'mock-u-001',
      email: event.email.isEmpty ? 'demo@sportpro.com' : event.email,
      name: event.name.isEmpty ? 'VĐV Sport Pro' : event.name,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      createdAt: DateTime.now(),
    );
    
    emit(AuthAuthenticated(mockUser));
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
}
