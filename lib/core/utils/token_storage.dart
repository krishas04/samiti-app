import 'package:shared_preferences/shared_preferences.dart';

// Persists and retrieves JWT strings using SharedPreferences.
//
// How authentication works with this backend:
//   1. Login → server returns access_token (JWT) + refresh_token (JWT)
//   2. Every API call → `Authorization: Bearer <accessToken>` (raw JWT string)
//   3. Server decodes the JWT and reads `auth_token` claim internally
//   4. When access JWT expires → POST refresh_token → get new access_token
//
// The client only ever stores and forwards the raw JWT strings.
// It never needs to read the `auth_token` claim inside the JWT.
class TokenStorage {
  static const _accessKey  = 'access_token';
  static const _refreshKey = 'refresh_token';

  // Save both raw JWT strings after a successful login or token refresh.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey,  accessToken);
    await prefs.setString(_refreshKey, refreshToken);
  }

  // Save only the access token (used after a token refresh call
  // which returns only a new access_token).
  static Future<void> saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, accessToken);
  }

  // The raw access JWT — send this in `Authorization: Bearer <value>`.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  // The raw refresh JWT — send this to `/token/refresh/` when access expires.
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  // Remove all stored tokens (call on logout).
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  // Returns true if an access token is currently stored.
  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}