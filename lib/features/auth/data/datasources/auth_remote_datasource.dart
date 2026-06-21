import 'package:flutter_specialized_temp/core/network/config/dio_client.dart';
import 'package:flutter_specialized_temp/features/auth/data/models/login_request_model.dart';
import 'package:flutter_specialized_temp/features/auth/data/models/register_request_model.dart';
import 'package:flutter_specialized_temp/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(LoginRequestModel request);
  Future<UserModel> register(RegisterRequestModel request);
  Future<void> logout();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<UserModel> login(LoginRequestModel request) async {
    final response = await _dioClient.client.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> register(RegisterRequestModel request) async {
    final response = await _dioClient.client.post<Map<String, dynamic>>(
      '/auth/register',
      data: request.toJson(),
    );
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<void> logout() async {
    await _dioClient.client.post<void>('/auth/logout');
  }
}
