import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    this.name,
    this.phone,
    this.role,
  });

  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? role;
  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    role,
    accessToken,
    refreshToken,
  ];
}
