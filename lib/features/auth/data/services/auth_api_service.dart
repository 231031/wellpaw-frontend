import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/features/auth/data/models/auth_models.dart';

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
    String? deviceToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/login');
    final payload = <String, dynamic>{'email': email, 'password': password};
    if (deviceToken != null && deviceToken.isNotEmpty) {
      payload['device_token'] = deviceToken;
    }

    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final message = body['message']?.toString() ?? 'Login failed';
      throw Exception(message);
    }

    return AuthResponse.fromJson(body);
  }

  Future<RegisterResponse> registerAccount({
    required String fullName,
    required String email,
    required String password,
    String? deviceToken,
    bool notiFood = false,
    bool notiCalendars = false,
    bool profileFree = false,
    bool foodFree = false,
    bool foodPlanFree = false,
    bool bcsFree = false,
    bool diseaseFree = false,
    String paymentPlan = '',
    String subscriptionStatus = '',
    String tier = '',
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/register');
    final trimmed = fullName.trim();
    final parts = trimmed.split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final payload = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'noti_food': notiFood,
      'noti_calendars': notiCalendars,
      'profile_free': profileFree,
      'food_free': foodFree,
      'food_plan_free': foodPlanFree,
      'bcs_free': bcsFree,
      'disease_free': diseaseFree,
      'payment_plan': paymentPlan,
      'subscription_status': subscriptionStatus,
      'tier': tier,
    };
    if (deviceToken != null && deviceToken.isNotEmpty) {
      payload['device_token'] = deviceToken;
    }

    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = body['message']?.toString() ?? 'Register failed';
      throw Exception(message);
    }

    return RegisterResponse.fromJson(body);
  }

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
