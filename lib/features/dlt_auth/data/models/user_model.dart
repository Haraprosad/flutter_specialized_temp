import 'package:flutter_specialized_temp/features/dlt_auth/domain/entities/user_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String accessToken,
    required String refreshToken,
    String? name,
    String? phone,
    String? role,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    name: name,
    phone: phone,
    role: role,
    accessToken: accessToken,
    refreshToken: refreshToken,
  );
}
