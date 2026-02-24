import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/features/auth/data/models/auth_models.dart';

class UserApiService {
  UserApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, dynamic> _decodeJsonMap(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  Exception _buildHttpException(
    http.Response response,
    Map<String, dynamic> body,
  ) {
    final message = body['message']?.toString();
    if (message != null && message.isNotEmpty) {
      return Exception(message);
    }

    final rawBody = response.body.trim();
    if (rawBody.isNotEmpty) {
      final lower = rawBody.toLowerCase();
      if (lower.contains('runtime error') ||
          lower.contains('nil pointer') ||
          response.statusCode >= 500) {
        return Exception('เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่อีกครั้ง');
      }

      return Exception(rawBody);
    }

    if (response.statusCode >= 500) {
      return Exception('เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่อีกครั้ง');
    }

    return Exception('Request failed (${response.statusCode})');
  }

  Future<AuthUser> fetchCurrentUser({required String accessToken}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/user');

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
      throw Exception(
        'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบว่า backend ทำงานอยู่',
      );
    }

    final body = _decodeJsonMap(response);
    if (response.statusCode != 200) {
      throw _buildHttpException(response, body);
    }

    final userJson = _extractUserJson(body);
    if (userJson == null) {
      throw Exception('ไม่พบข้อมูลผู้ใช้ในผลลัพธ์');
    }

    return AuthUser.fromJson(userJson);
  }

  Map<String, dynamic>? _extractUserJson(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final user = data['user'];
      if (user is Map<String, dynamic>) {
        return user;
      }

      if (data.containsKey('email')) {
        return data;
      }
    }

    final user = body['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }

    if (body.containsKey('email')) {
      return body;
    }

    return null;
  }
}
