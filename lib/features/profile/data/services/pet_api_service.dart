import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/features/profile/data/models/pet_models.dart';

class PetApiService {
  PetApiService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<void> createPet({
    required String accessToken,
    required CreatePetPayload payload,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/pet');
    final requestBody = jsonEncode(payload.toJson());
    // Debug: log payload
    // ignore: avoid_print
    print('POST /pet payload: $requestBody');
    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: requestBody,
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
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _buildHttpException(response, body);
    }
  }

  Future<void> updatePetInfo({
    required String accessToken,
    required PetInfoPayload payload,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/pet/info');
    final requestBody = jsonEncode(payload.toJson());
    // Debug: log payload
    // ignore: avoid_print
    print('PATCH /pet/info payload: $requestBody');
    late final http.Response response;
    try {
      response = await _client
          .patch(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: requestBody,
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
  }

  Future<void> updatePetDetail({
    required String accessToken,
    required PetDetailPayload payload,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/pet/detail');
    final requestBody = jsonEncode(payload.toJson());
    // Debug: log payload
    // ignore: avoid_print
    print('POST /pet/detail payload: $requestBody');
    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: requestBody,
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
  }

  Future<void> deletePet({
    required String accessToken,
    required int petId,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/pet/$petId');
    late final http.Response response;
    try {
      response = await _client
          .delete(
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
  }
}
