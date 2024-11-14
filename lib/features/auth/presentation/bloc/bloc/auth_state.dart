part of 'auth_bloc.dart';

abstract class AuthState extends Equatable{
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}


class AuthAuthenticated extends AuthState {
  final String email;
  
  const AuthAuthenticated({
    required this.email,
  });
  
  @override
  List<Object?> get props => [email];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError({
    required this.message,
  });
  
  @override
  List<Object?> get props => [message];
}