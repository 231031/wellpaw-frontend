import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/features/auth/data/models/subscription_models.dart';

class SubscriptionApiService {
  SubscriptionApiService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<SubscriptionPlan>> fetchPlans({
    required String accessToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/user/subscription');
    late final http.Response response;
    try {
      response = await _client
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    }

    final body = _decodeJson(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        _messageFrom(body) ?? 'Request failed (${response.statusCode})',
      );
    }

    final data = body['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(SubscriptionPlan.fromJson)
          .toList();
    }

    return <SubscriptionPlan>[];
  }

  Future<void> updatePaymentMethod({
    required String accessToken,
    required String paymentMethodId,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/user/payment/paymentmethod');
    late final http.Response response;
    try {
      response = await _client
          .patch(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'payment_method_id': paymentMethodId}),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    }

    final body = _decodeJson(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _messageFrom(body) ?? 'Request failed (${response.statusCode})',
      );
    }
  }

  Future<StartSubscriptionResult> startSubscription({
    required String accessToken,
    required String subscriptionPlanId,
    String? paymentMethodId,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/user/subscription/start');
    final payload = <String, dynamic>{
      'subscription_plan_id': subscriptionPlanId,
    };
    if (paymentMethodId != null && paymentMethodId.trim().isNotEmpty) {
      payload['payment_method_id'] = paymentMethodId.trim();
    }
    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    }

    final body = _decodeJson(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _messageFrom(body) ?? 'Request failed (${response.statusCode})',
      );
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final merged = <String, dynamic>{...data};

      final token = data['token'];
      if (token is Map<String, dynamic>) {
        merged['access_token'] =
            token['access_token']?.toString() ?? merged['access_token'];
        merged['refresh_token'] =
            token['refresh_token']?.toString() ?? merged['refresh_token'];
      }

      if (body['access_token'] != null) {
        merged['access_token'] = body['access_token']?.toString();
      }
      if (body['refresh_token'] != null) {
        merged['refresh_token'] = body['refresh_token']?.toString();
      }

      return StartSubscriptionResult.fromJson(merged);
    }

    return StartSubscriptionResult(
      clientSecret: '',
      accessToken: body['access_token']?.toString(),
      refreshToken: body['refresh_token']?.toString(),
    );
  }

  Map<String, dynamic> _decodeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  String? _messageFrom(Map<String, dynamic> body) {
    final message = body['message'];
    if (message != null) {
      return message.toString();
    }
    return null;
  }
}
