import 'dart:convert';

// Strongly-typed representation of your JWT payload.
// Both access and refresh tokens share this shape:
// {
//   "type":       "access" | "refresh" | "verify",
//   "auth_token": "WyJhZ...",   ← server-side user identifier (NOT used in headers)
//   "exp":        1784797237,
//   "iat":        1777021237
// }
// IMPORTANT: The raw JWT string itself is what goes in
// `Authorization: Bearer <rawJwt>`. The server decodes it on its end
// and reads `auth_token` internally — the client never touches auth_token.
class JwtPayload {
  final String type;  // "access", "refresh", or "verify"

  // Server-side user identifier embedded in the token.
  // The client does NOT send this in headers — it is for server use only.
  final String authToken;

  final DateTime expiresAt;
  final DateTime issuedAt;

  JwtPayload({
    required this.type,
    required this.authToken,
    required this.expiresAt,
    required this.issuedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// Decodes a JWT string and returns its payload claims.
// Does NOT verify the signature — for client-side expiry checking only.
class JwtDecoder {
  // Returns the raw decoded payload map from a JWT string.
  static Map<String, dynamic> decode(String jwtString) {
    final parts = jwtString.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT format: expected 3 dot-separated parts.');
    }
    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  // Decodes a JWT string into a typed [JwtPayload].
  // Throws [FormatException] if required claims are absent.
  static JwtPayload decodePayload(String jwtString) {
    final map = decode(jwtString);

    final type      = map['type']       as String?;
    final authToken = map['auth_token'] as String?;
    final exp       = map['exp']        as int?;
    final iat       = map['iat']        as int?;

    if (type == null || authToken == null || exp == null || iat == null) {
      throw const FormatException(
          'JWT payload missing required fields: type, auth_token, exp, iat.');
    }

    return JwtPayload(
      type:      type,
      authToken: authToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(exp * 1000), //As backend returns seconds but dart works with milliseconds
      issuedAt:  DateTime.fromMillisecondsSinceEpoch(iat * 1000),
    );
  }

  // Returns true if the JWT's `exp` claim is in the past.
  static bool isExpired(String jwtString) {
    try {
      return decodePayload(jwtString).isExpired;
    } catch (_) {
      return true;
    }
  }

  // Returns the expiry [DateTime], or null on failure.
  static DateTime? getExpiryDate(String jwtString) {
    try {
      return decodePayload(jwtString).expiresAt;
    } catch (_) {
      return null;
    }
  }
}