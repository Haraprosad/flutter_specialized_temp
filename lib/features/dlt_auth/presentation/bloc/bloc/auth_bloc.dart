import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/logger/app_logger.dart';

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


  
  // Rest of the methods remain the same...
  Future<void> _handleLogin(
      LoginRequested event, Emitter<AuthState> emit) async {
    await Future.delayed(const Duration(seconds: 1));


      emit(const AuthAuthenticated(email: "test@example.com"));

  }

  Future<void> _handleLogout(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }

  Future<void> _handleRegister(
      RegisterRequested event, Emitter<AuthState> emit) async {
    await Future.delayed(const Duration(seconds: 1));

    emit(const AuthAuthenticated(email: "example@gmail.com"));
  }
}
