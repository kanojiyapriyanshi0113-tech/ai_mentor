import 'dart:convert';

/// Minimal JWT payload decoder - decodes and reads claims only,
/// does not verify the signature (verification happens server-side).
class JwtDecoder {
  JwtDecoder._();

  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT');
    }
    final payload = _decodeBase64(parts[1]);
    return jsonDecode(payload) as Map<String, dynamic>;
  }

  static String? role(String token) {
    try {
      final claims = decode(token);
      return claims['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw const FormatException('Illegal base64url string');
    }
    return utf8.decode(base64Url.decode(output));
  }
}
