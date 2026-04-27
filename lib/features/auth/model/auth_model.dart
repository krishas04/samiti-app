// Model file includes those fields returned in the API response,
// plus the conversion logic (fromJson, toJson).

import '../../../core/utils/jwt_decoder.dart';

class AuthModel {
  final String accessToken;
  final String refreshToken;
  // Expiry time decoded from [accessToken] for client-side expiry checks.
  final DateTime accessExpiresAt;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
  });

  // Build from the login API JSON response.
  factory AuthModel.fromJson(Map<String, dynamic> json){
    final accessToken  = json['access_token']  as String;
    final refreshToken = json['refresh_token'] as String;
    final expiresAt = JwtDecoder.getExpiryDate(accessToken) ?? DateTime.now();

    return AuthModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessExpiresAt: expiresAt,
    );
  }

  // Build from a token refresh API response (only returns access_token).
  factory AuthModel.fromRefreshJson(
      Map<String, dynamic> json, {
        required String existingRefreshToken,
      }) {
    final accessToken = json['access_token'] as String;
    final expiresAt   = JwtDecoder.getExpiryDate(accessToken) ?? DateTime.now();

    return AuthModel(
      accessToken:     accessToken,
      refreshToken:    existingRefreshToken,
      accessExpiresAt: expiresAt,
    );
  }

  // computed getter that returns true if the access token is already expired
  bool get isAccessExpired => DateTime.now().isAfter(accessExpiresAt);
}