import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    AppLogger.d(message: "AuthBloc initialized");
    on<LoginRequested>(_handleLogin);
    on<LogoutRequested>(_handleLogout);
    on<RegisterRequested>(_handleRegister);
  }

  Future<void> _handleLogin(
      LoginRequested event, Emitter<AuthState> emit) async {
    await Future.delayed(const Duration(seconds: 1));

    emit(const AuthAuthenticated(email: "test@example.com"));

    // When login is successful, save to local storage
    if (state is AuthAuthenticated) {
      final storage = sl<AppStorage>();
      await storage.preferences.setIsAuthenticated(true);
      // Add role if you have role-based system
      // await storage.preferences.setUserRole(user.role);
    }
  }

  Future<void> _handleLogout(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());

    // Clear local storage on logout
    final storage = sl<AppStorage>();
    await storage.preferences.setIsAuthenticated(false);
    await storage
        .clearAllData(); // This will clear both secure and preferences data
  }

  Future<void> _handleRegister(
      RegisterRequested event, Emitter<AuthState> emit) async {
    await Future.delayed(const Duration(seconds: 1));

    emit(const AuthAuthenticated(email: "example@gmail.com"));
  }
}
