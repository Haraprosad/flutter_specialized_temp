import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? role;
  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [id, email, name, phone, role, accessToken, refreshToken];
}
