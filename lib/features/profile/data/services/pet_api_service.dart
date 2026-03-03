import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/features/profile/data/models/pet_models.dart';

class PetApiService {
  PetApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  bool _isSuccessStatus(int statusCode) {
    return statusCode == 200 || statusCode == 201 || statusCode == 204;
  }

  bool _isRetryableRouteStatus(int statusCode) {
    return statusCode == 404 || statusCode == 405;
  }

  Future<http.Response> _sendJsonRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) {
    switch (method.toUpperCase()) {
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: body);
      case 'PUT':
        return _client.put(uri, headers: headers, body: body);
      case 'POST':
        return _client.post(uri, headers: headers, body: body);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  Future<http.Response> _updateWithFallback({
    required String accessToken,
    required String requestBody,
    required List<Uri> uris,
    required List<String> methods,
  }) async {
    final headers = <String, String>{
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    http.Response? fallbackResponse;

    for (final uri in uris) {
      for (final method in methods) {
        // ignore: avoid_print
        print('TRY $method ${uri.path}');
        final response = await _sendJsonRequest(
          method: method,
          uri: uri,
          headers: headers,
          body: requestBody,
        ).timeout(const Duration(seconds: 15));

        // ignore: avoid_print
        print('RESP ${response.statusCode} $method ${uri.path}');

        if (_isSuccessStatus(response.statusCode)) {
          return response;
        }

        if (_isRetryableRouteStatus(response.statusCode)) {
          fallbackResponse = response;
          continue;
        }

        return response;
      }
    }

    return fallbackResponse ??
        http.Response('Update endpoint not found', 404, request: null);
  }

  dynamic _decodeJson(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      return null;
    }
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      final result = <String, dynamic>{};
      value.forEach((key, dynamic item) {
        result[key.toString()] = item;
      });
      return result;
    }
    return <String, dynamic>{};
  }

  String? _extractMessage(dynamic body) {
    if (body is String) {
      final text = body.trim();
      return text.isEmpty ? null : text;
    }

    if (body is Map) {
      final map = _toMap(body);
      final topMessage = map['message']?.toString().trim();
      if (topMessage != null && topMessage.isNotEmpty) {
        return topMessage;
      }

      final error = map['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }

      final dataMessage = _extractMessage(map['data']);
      if (dataMessage != null && dataMessage.isNotEmpty) {
        return dataMessage;
      }

      final resultMessage = _extractMessage(map['result']);
      if (resultMessage != null && resultMessage.isNotEmpty) {
        return resultMessage;
      }
    }

    if (body is List) {
      for (final item in body) {
        final message = _extractMessage(item);
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
    }

    return null;
  }

  Exception _buildHttpException(http.Response response, dynamic body) {
    final message = _extractMessage(body);
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

  int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final text = value.trim();
      final direct = int.tryParse(text);
      if (direct != null) {
        return direct;
      }

      final firstNumber = RegExp(r'-?\d+').firstMatch(text)?.group(0);
      if (firstNumber != null) {
        return int.tryParse(firstNumber);
      }
    }
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final text = value.trim().replaceAll(',', '.');
      final direct = double.tryParse(text);
      if (direct != null) {
        return direct;
      }

      final firstNumber = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(text)?.group(0);
      if (firstNumber != null) {
        return double.tryParse(firstNumber);
      }
    }
    return null;
  }

  bool? _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1') {
        return true;
      }
      if (lower == 'false' || lower == '0') {
        return false;
      }
    }
    return null;
  }

  String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _mapPetType(dynamic value) {
    if (value is int) {
      return value == 1 ? 'แมว' : 'สุนัข';
    }

    final raw = _asString(value).toLowerCase();
    if (raw.contains('cat') || raw.contains('แมว') || raw == '1') {
      return 'แมว';
    }
    return 'สุนัข';
  }

  String _mapGender(dynamic value) {
    if (value is int) {
      return value == 1 ? 'ตัวเมีย' : 'ตัวผู้';
    }

    final raw = _asString(value).toLowerCase();
    if (raw.contains('female') || raw.contains('เมีย') || raw == '1') {
      return 'ตัวเมีย';
    }
    return 'ตัวผู้';
  }

  String _normalizeBirthDate(dynamic value) {
    final text = _asString(value);
    if (text.isEmpty) {
      return '-';
    }
    return text.length >= 10 ? text.substring(0, 10) : text;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return _toMap(value);
    }
    return null;
  }

  Map<String, dynamic>? _firstMapFromList(dynamic value) {
    if (value is List) {
      for (final item in value) {
        final mapped = _asMap(item);
        if (mapped != null) {
          return mapped;
        }
      }
    }
    return null;
  }

  int _metricScore(Map<String, dynamic>? map) {
    if (map == null) {
      return 0;
    }

    var score = 0;
    if (_asDouble(map['weight'] ?? map['weight_kg'] ?? map['weightKg']) !=
        null) {
      score += 1;
    }
    if (_asInt(
          map['activity_level'] ??
              map['activity_level_id'] ??
              map['activityLevel'] ??
              map['activityLevelId'] ??
              map['activity'],
        ) !=
        null) {
      score += 1;
    }
    if (_asInt(
          map['bcs'] ??
              map['bcs_score'] ??
              map['body_condition_score'] ??
              map['bodyConditionScore'],
        ) !=
        null) {
      score += 1;
    }

    return score;
  }

  DateTime? _asDateTime(dynamic value) {
    final text = _asString(value);
    if (text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }

  Map<String, dynamic>? _bestMetricMapFromList(dynamic value) {
    final list = _extractMapList(value);
    if (list.isEmpty) {
      return null;
    }

    list.sort((a, b) {
      final scoreCompare = _metricScore(b).compareTo(_metricScore(a));
      if (scoreCompare != 0) {
        return scoreCompare;
      }

      final dateA = _asDateTime(a['created_at'] ?? a['updated_at']);
      final dateB = _asDateTime(b['created_at'] ?? b['updated_at']);
      if (dateA == null && dateB == null) {
        return 0;
      }
      if (dateA == null) {
        return 1;
      }
      if (dateB == null) {
        return -1;
      }
      return dateB.compareTo(dateA);
    });

    return list.first;
  }

  bool _hasAnyMetric(Map<String, dynamic>? map) {
    if (map == null) {
      return false;
    }

    return map.containsKey('weight') ||
        map.containsKey('weight_kg') ||
        map.containsKey('weightKg') ||
        map.containsKey('latest_weight') ||
        map.containsKey('latestWeight') ||
        map.containsKey('current_weight') ||
        map.containsKey('currentWeight') ||
        map.containsKey('activity_level') ||
        map.containsKey('activity_level_id') ||
        map.containsKey('activityLevelId') ||
        map.containsKey('activity') ||
        map.containsKey('activityLevel') ||
        map.containsKey('bcs') ||
        map.containsKey('bcs_score') ||
        map.containsKey('body_condition_score') ||
        map.containsKey('bodyConditionScore');
  }

  String? _toAbsoluteImageUrl(String rawPath) {
    final path = rawPath.trim();
    if (path.isEmpty) {
      return null;
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final base = Uri.parse(AppConfig.apiBaseUrl);
    final origin = base.hasPort
        ? '${base.scheme}://${base.host}:${base.port}'
        : '${base.scheme}://${base.host}';

    if (path.startsWith('/')) {
      return '$origin$path';
    }

    return '$origin/$path';
  }

  List<Map<String, dynamic>> _extractMapList(dynamic value) {
    if (value is List) {
      return value.map(_asMap).whereType<Map<String, dynamic>>().toList();
    }
    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _extractPetsList(dynamic responseBody) {
    if (responseBody is List) {
      return _extractMapList(responseBody);
    }

    final body = _toMap(responseBody);
    final topLevel = _extractMapList(body['pets']);
    if (topLevel.isNotEmpty) {
      return topLevel;
    }

    final topLevelRows = _extractMapList(body['rows']);
    if (topLevelRows.isNotEmpty) {
      return topLevelRows;
    }

    final topLevelItems = _extractMapList(body['items']);
    if (topLevelItems.isNotEmpty) {
      return topLevelItems;
    }

    final topLevelResult = _extractMapList(body['result']);
    if (topLevelResult.isNotEmpty) {
      return topLevelResult;
    }

    final topLevelResults = _extractMapList(body['results']);
    if (topLevelResults.isNotEmpty) {
      return topLevelResults;
    }

    final data = body['data'];
    if (data is List) {
      return _extractMapList(data);
    }

    if (data is Map<String, dynamic>) {
      final fromDataPets = _extractMapList(data['pets']);
      if (fromDataPets.isNotEmpty) {
        return fromDataPets;
      }

      final fromDataItems = _extractMapList(data['items']);
      if (fromDataItems.isNotEmpty) {
        return fromDataItems;
      }

      final fromDataList = _extractMapList(data['list']);
      if (fromDataList.isNotEmpty) {
        return fromDataList;
      }

      final fromDataRows = _extractMapList(data['rows']);
      if (fromDataRows.isNotEmpty) {
        return fromDataRows;
      }

      final fromDataResult = _extractMapList(data['result']);
      if (fromDataResult.isNotEmpty) {
        return fromDataResult;
      }

      final fromDataResults = _extractMapList(data['results']);
      if (fromDataResults.isNotEmpty) {
        return fromDataResults;
      }

      if (data['pet'] is Map<String, dynamic>) {
        return [data];
      }

      if (data['pet_info'] is Map ||
          data['petInfo'] is Map ||
          data['pet_detail'] is Map ||
          data['petDetail'] is Map) {
        return [data];
      }
    }

    final resultMap = _asMap(body['result']);
    if (resultMap != null) {
      final fromResultPets = _extractMapList(resultMap['pets']);
      if (fromResultPets.isNotEmpty) {
        return fromResultPets;
      }

      final fromResultItems = _extractMapList(resultMap['items']);
      if (fromResultItems.isNotEmpty) {
        return fromResultItems;
      }

      final fromResultList = _extractMapList(resultMap['list']);
      if (fromResultList.isNotEmpty) {
        return fromResultList;
      }

      if (resultMap['pet_info'] is Map ||
          resultMap['petInfo'] is Map ||
          resultMap['pet_detail'] is Map ||
          resultMap['petDetail'] is Map) {
        return [resultMap];
      }
    }

    if (body['pet_info'] is Map ||
        body['petInfo'] is Map ||
        body['pet_detail'] is Map ||
        body['petDetail'] is Map ||
        body['pet'] is Map) {
      return [body];
    }

    return const <Map<String, dynamic>>[];
  }

  PetProfileData _mapPetProfile(Map<String, dynamic> source) {
    final info =
        _asMap(source['pet_info']) ??
        _asMap(source['petInfo']) ??
        _asMap(source['pet']) ??
        source;

    final latestPetDetailFromList =
        _bestMetricMapFromList(source['pet_details']) ??
        _bestMetricMapFromList(source['petDetails']) ??
        _bestMetricMapFromList(info['pet_details']) ??
        _bestMetricMapFromList(info['petDetails']) ??
        _firstMapFromList(source['pet_details']) ??
        _firstMapFromList(source['petDetails']) ??
        _firstMapFromList(info['pet_details']) ??
        _firstMapFromList(info['petDetails']);

    final detail =
        latestPetDetailFromList ??
        _asMap(source['pet_detail']) ??
        _asMap(source['petDetail']) ??
        _asMap(source['detail']) ??
        _asMap(source['latest_pet_detail']) ??
        _asMap(source['latestPetDetail']) ??
        source;

    final history =
        _bestMetricMapFromList(source['pet_food_plan_histories']) ??
        _bestMetricMapFromList(source['pet_detail_histories']) ??
        _firstMapFromList(source['pet_food_plan_histories']) ??
        _firstMapFromList(source['pet_detail_histories']) ??
        _asMap(source['pet_food_plan_history']) ??
        _asMap(source['pet_detail_history']);

    final metricCandidates = <Map<String, dynamic>>[
      detail,
      if (history != null) history,
      source,
      info,
    ];

    metricCandidates.sort((a, b) => _metricScore(b).compareTo(_metricScore(a)));
    final metricSource = metricCandidates.first;

    final id =
        _asInt(info['id']) ??
        _asInt(info['pet_id']) ??
        _asInt(info['petId']) ??
        _asInt(source['id']) ??
        _asInt(source['pet_id']) ??
        _asInt(source['petId']) ??
        0;

    final weightValue =
        _asDouble(metricSource['weight']) ??
        _asDouble(metricSource['weight_kg']) ??
        _asDouble(metricSource['weightKg']) ??
        _asDouble(detail['weight']) ??
        _asDouble(detail['weight_kg']) ??
        _asDouble(detail['weightKg']) ??
        _asDouble(history?['weight']) ??
        _asDouble(history?['weight_kg']) ??
        _asDouble(history?['weightKg']) ??
        _asDouble(source['weight']) ??
        _asDouble(source['weight_kg']) ??
        _asDouble(source['weightKg']) ??
        _asDouble(source['latest_weight']) ??
        _asDouble(source['latestWeight']) ??
        _asDouble(source['current_weight']) ??
        _asDouble(source['currentWeight']);

    final activityLevel =
        _asInt(metricSource['activity_level']) ??
        _asInt(metricSource['activity']) ??
        _asInt(metricSource['activityLevel']) ??
        _asInt(metricSource['activity_level_id']) ??
        _asInt(metricSource['activityLevelId']) ??
        _asInt(source['activity_level']) ??
        _asInt(source['activity']) ??
        _asInt(source['activityLevel']) ??
        _asInt(source['activity_level_id']) ??
        _asInt(source['activityLevelId']);

    final bcsValue =
        _asInt(metricSource['bcs']) ??
        _asInt(metricSource['bcs_score']) ??
        _asInt(metricSource['body_condition_score']) ??
        _asInt(metricSource['bodyConditionScore']) ??
        _asInt(source['bcs']) ??
        _asInt(source['bcs_score']) ??
        _asInt(source['body_condition_score']) ??
        _asInt(source['bodyConditionScore']);

    final imagePath = _asString(
      info['image_path'] ??
          info['imagePath'] ??
          info['photo_url'] ??
          info['photoUrl'] ??
          source['image_path'] ??
          source['imagePath'] ??
          source['photo_url'] ??
          source['photoUrl'],
    ).trim();

    final weightText = weightValue == null
        ? ''
        : (weightValue % 1 == 0
              ? weightValue.toInt().toString()
              : weightValue.toStringAsFixed(1));

    return PetProfileData(
      id: id,
      name: _asString(
        info['name'] ?? info['pet_name'] ?? info['petName'],
        fallback: 'ไม่ระบุชื่อ',
      ),
      weightLabel: weightText.isEmpty ? 'ไม่ระบุน้ำหนัก' : '$weightText kg',
      type: _mapPetType(info['type'] ?? info['pet_type'] ?? info['petType']),
      breed: _asString(info['breed'] ?? info['breed_name'], fallback: '-'),
      gender: _mapGender(info['sex_type'] ?? info['gender'] ?? info['sex']),
      birthDate: _normalizeBirthDate(
        info['birth_date'] ??
            info['birthDate'] ??
            info['dob'] ??
            info['birthday'],
      ),
      weight: weightText,
      imagePath: _toAbsoluteImageUrl(imagePath),
      activityLevel: activityLevel,
      bcs: bcsValue,
    );
  }

  Map<String, dynamic>? _extractAnalysisMap(Map<String, dynamic> body) {
    if (body['analysis'] is Map<String, dynamic>) {
      return body['analysis'] as Map<String, dynamic>;
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      if (data['analysis'] is Map<String, dynamic>) {
        return data['analysis'] as Map<String, dynamic>;
      }

      if (data['pet_analysis'] is Map<String, dynamic>) {
        return data['pet_analysis'] as Map<String, dynamic>;
      }

      if (data['petAnalysis'] is Map<String, dynamic>) {
        return data['petAnalysis'] as Map<String, dynamic>;
      }

      if (data['pet_detail'] is Map<String, dynamic>) {
        return data['pet_detail'] as Map<String, dynamic>;
      }

      if (data['detail'] is Map<String, dynamic>) {
        return data['detail'] as Map<String, dynamic>;
      }

      final fromHistories =
          _firstMapFromList(data['pet_food_plan_histories']) ??
          _firstMapFromList(data['pet_detail_histories']) ??
          _asMap(data['pet_food_plan_history']) ??
          _asMap(data['pet_detail_history']);
      if (fromHistories != null) {
        return fromHistories;
      }

      if (_hasAnyMetric(data)) {
        return data;
      }

      return data;
    }

    final result = body['result'];
    if (result is Map<String, dynamic>) {
      final fromResult = _extractAnalysisMap({'data': result});
      if (fromResult != null) {
        return fromResult;
      }
      return result;
    }

    if (_hasAnyMetric(body)) {
      return body;
    }

    return null;
  }

  Future<List<PetProfileData>> fetchMyPets({
    required String accessToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/pets');

    late http.Response response;
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

    final body = _decodeJson(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _buildHttpException(response, body);
    }

    final pets = _extractPetsList(body);
    return pets.map(_mapPetProfile).where((pet) => pet.id > 0).toList();
  }

  Future<PetProfileData?> fetchPetById({
    required String accessToken,
    required int petId,
  }) async {
    final pets = await fetchMyPets(accessToken: accessToken);
    for (final pet in pets) {
      if (pet.id == petId) {
        return pet;
      }
    }
    return null;
  }

  Future<PetAnalysisData?> fetchPetAnalysis({
    required String accessToken,
    required int petId,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/pet/analysis/$petId');

    late http.Response response;
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

    final body = _decodeJson(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _buildHttpException(response, body);
    }

    final normalizedBody = _toMap(body);
    final analysis = _extractAnalysisMap(normalizedBody);
    if (analysis == null) {
      return null;
    }

    final data =
        _asMap(normalizedBody['data']) ?? _asMap(normalizedBody['result']);
    final petInfo = _asMap(data?['pet']) ?? _asMap(normalizedBody['pet']);
    final imagePath = _asString(
      petInfo?['image_path'] ?? data?['image_path'] ?? analysis['image_path'],
    );

    return PetAnalysisData(
      weight:
          _asDouble(analysis['weight']) ??
          _asDouble(analysis['weight_kg']) ??
          _asDouble(analysis['weightKg']) ??
          _asDouble(analysis['latest_weight']) ??
          _asDouble(analysis['latestWeight']) ??
          _asDouble(analysis['current_weight']) ??
          _asDouble(analysis['currentWeight']),
      activityLevel:
          _asInt(analysis['activity_level']) ??
          _asInt(analysis['activityLevel']) ??
          _asInt(analysis['activity']) ??
          _asInt(analysis['activity_level_id']) ??
          _asInt(analysis['activityLevelId']),
      bcs:
          _asInt(analysis['bcs']) ??
          _asInt(analysis['bcs_score']) ??
          _asInt(analysis['body_condition_score']) ??
          _asInt(analysis['bodyConditionScore']),
      neutered: _asBool(analysis['neutered']),
      lactation: _asBool(analysis['lactation']),
      gestation: _asBool(analysis['gestation']),
      gestationStartDate: _asString(
        analysis['gestation_startdate'] ?? analysis['gestation_start_date'],
      ),
      imagePath: _toAbsoluteImageUrl(imagePath),
    );
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

    final body = _decodeJson(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _buildHttpException(response, body);
    }
  }

  Future<void> updatePetInfo({
    required String accessToken,
    required PetInfoPayload payload,
  }) async {
    final requestBody = jsonEncode(payload.toJson());
    // Debug: log payload
    // ignore: avoid_print
    print('UPDATE /pet/info payload: $requestBody');
    late http.Response response;
    try {
      final petId = payload.petId;
      response = await _updateWithFallback(
        accessToken: accessToken,
        requestBody: requestBody,
        uris: [
          Uri.parse('${AppConfig.apiBaseUrl}/pet/info'),
          Uri.parse('${AppConfig.apiBaseUrl}/pet/info/'),
          Uri.parse('${AppConfig.apiBaseUrl}/pet/$petId/info'),
          Uri.parse('${AppConfig.apiBaseUrl}/pet/$petId'),
          Uri.parse('${AppConfig.apiBaseUrl}/pet'),
        ],
        methods: const ['PATCH', 'PUT', 'POST'],
      );
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception(
        'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบว่า backend ทำงานอยู่',
      );
    }

    final body = _decodeJson(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw _buildHttpException(response, body);
    }
  }

  Future<void> updatePetDetail({
    required String accessToken,
    required PetDetailPayload payload,
  }) async {
    final requestBody = jsonEncode(payload.toJson());
    // Debug: log payload
    // ignore: avoid_print
    print('UPDATE /pet/detail payload: $requestBody');
    late http.Response response;
    try {
      final petId = payload.petId;
      response = await _updateWithFallback(
        accessToken: accessToken,
        requestBody: requestBody,
        uris: [
          Uri.parse('${AppConfig.apiBaseUrl}/pet/detail'),
          Uri.parse('${AppConfig.apiBaseUrl}/pet/detail/'),
          Uri.parse('${AppConfig.apiBaseUrl}/pet/$petId/detail'),
          Uri.parse('${AppConfig.apiBaseUrl}/pet/$petId/analysis'),
          Uri.parse('${AppConfig.apiBaseUrl}/pet/$petId'),
        ],
        methods: const ['POST', 'PATCH', 'PUT'],
      );
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception(
        'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบว่า backend ทำงานอยู่',
      );
    }

    final body = _decodeJson(response);
    if (!_isSuccessStatus(response.statusCode)) {
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

    final body = _decodeJson(response);
    if (response.statusCode != 200) {
      throw _buildHttpException(response, body);
    }
  }
}
