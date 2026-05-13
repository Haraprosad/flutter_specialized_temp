import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_specialized_temp/core/exceptions/app_exceptions.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/entities/user_entity.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/usecases/login_usecase.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/domain/usecases/register_usecase.dart';
import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._loginUseCase, this._registerUseCase, this._logoutUseCase)
      : super(AuthInitial()) {
    AppLogger.d(message: 'AuthBloc initialized');
    on<LoginRequested>(_handleLogin);
    on<LogoutRequested>(_handleLogout);
    on<RegisterRequested>(_handleRegister);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> _handleLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _loginUseCase(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _handleLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _logoutUseCase();
      emit(AuthUnauthenticated());
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _handleRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _registerUseCase(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
      );
      emit(AuthAuthenticated(user: user));
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
