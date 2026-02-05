import 'dart:convert';

import 'package:well_paw/features/auth/data/models/auth_models.dart';
import 'package:well_paw/features/auth/data/services/auth_api_service.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';

class AuthTokenService {
  AuthTokenService({AuthApiService? authApi, TokenStorage? tokenStorage})
    : _authApi = authApi ?? AuthApiService(),
      _tokenStorage = tokenStorage ?? const TokenStorage();

  final AuthApiService _authApi;
  final TokenStorage _tokenStorage;

  Future<bool> ensureValidAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    if (!_isTokenExpired(accessToken)) {
      return true;
    }

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clear();
      return false;
    }

    try {
      final tokenPair = await _authApi.refreshTokens(
        refreshToken: refreshToken,
      );
      await _tokenStorage.saveTokens(
        accessToken: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
      );
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    }
  }

  bool _isTokenExpired(String token) {
    final payload = _decodeJwtPayload(token);
    if (payload == null) {
      return true;
    }

    final expValue = payload['exp'];
    if (expValue == null) {
      return true;
    }

    final expSeconds = expValue is int
        ? expValue
        : int.tryParse(expValue.toString());
    if (expSeconds == null) {
      return true;
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
    final now = DateTime.now().add(const Duration(seconds: 30));
    return !expiry.isAfter(now);
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
