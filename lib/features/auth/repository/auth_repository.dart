import 'package:samiti_app/core/api/api_service.dart';

import '../../../core/api/api_constants.dart';
import '../model/auth_model.dart';

class AuthRepository extends BaseApiService{
  AuthRepository({required super.client});

  Future<AuthModel> login({required String login, required String password}) async {
    final data = await post(
      endpoint: ApiConstants.login,
      body: {'login': login, 'password': password},
    );
    return AuthModel.fromJson(data);
  }

  Future<AuthModel> register({required String password, required String email,required String username}) async {
    final data= await post(
        endpoint: ApiConstants.register,
        body: {
          'password': password,
          'email': email,
          'username': username,
        });
    return AuthModel.fromJson(data);
  }

  // Exchange a refresh token for a new access token.
  // The backend returns only { "access_token": "..." }.
  Future<AuthModel> refreshToken({
    required String refreshToken,
  }) async {
    final data = await post(
      endpoint: ApiConstants.tokenRefresh,
      body: {'refresh_token': refreshToken},
    );
    return AuthModel.fromRefreshJson(data, existingRefreshToken: refreshToken);
  }
}