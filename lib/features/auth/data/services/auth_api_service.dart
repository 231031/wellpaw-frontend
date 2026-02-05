import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/features/auth/data/models/auth_models.dart';

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthResponse> loginWithGoogle({
    required String authCode,
    required String deviceToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/login/google');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'auth_code': authCode, 'device_token': deviceToken}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final message = body['message']?.toString() ?? 'Login failed';
      throw Exception(message);
    }

    return AuthResponse.fromJson(body);
  }

  Future<TokenPair> refreshTokens({required String refreshToken}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/refreshtoken');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final message = body['message']?.toString() ?? 'Refresh token failed';
      throw Exception(message);
    }

    return _parseTokenPair(body);
  }

  TokenPair _parseTokenPair(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final token = data['token'];
      if (token is Map<String, dynamic>) {
        return TokenPair.fromJson(token);
      }
    }

    final token = body['token'];
    if (token is Map<String, dynamic>) {
      return TokenPair.fromJson(token);
    }

    if (body['access_token'] != null && body['refresh_token'] != null) {
      return TokenPair(
        accessToken: body['access_token'] as String,
        refreshToken: body['refresh_token'] as String,
      );
    }

    throw Exception('Invalid token response');
  }
}
