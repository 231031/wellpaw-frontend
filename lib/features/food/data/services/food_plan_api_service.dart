import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:well_paw/core/config/app_config.dart';
import 'package:well_paw/features/food/data/models/food_plan_models.dart';

class FoodPlanApiService {
  FoodPlanApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void _debugFoodApiLog(String message) {
    if (kDebugMode) {
      debugPrint('[FoodAPI] $message');
    }
  }

  String _truncateForLog(String value, {int max = 1200}) {
    if (value.length <= max) {
      return value;
    }
    return '${value.substring(0, max)}...(truncated)';
  }

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
      if (decoded is List) {
        return <String, dynamic>{'data': decoded};
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

    if (response.statusCode >= 500) {
      return Exception('เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่อีกครั้ง');
    }

    return Exception('Request failed (${response.statusCode})');
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return const <Map<String, dynamic>>[];
  }

  String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  dynamic _pickValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key)) {
        return map[key];
      }
    }
    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  Map<String, String> _buildHeaders(String accessToken) {
    return {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Map<String, String> _buildAuthHeaders(String accessToken) {
    return {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };
  }

  bool _isSuccessStatus(int statusCode) {
    return statusCode == 200 || statusCode == 201 || statusCode == 204;
  }

  bool _isNoDataStatus(int statusCode) {
    return statusCode == 404 || statusCode == 400;
  }

  bool _looksLikeNoDataMessage(Map<String, dynamic> body) {
    final message = _asString(body['message']).toLowerCase();
    if (message.isEmpty) {
      return false;
    }

    return message.contains('not found') ||
        message.contains('no food') ||
        message.contains('ไม่มี') ||
        message.contains('ไม่พบ');
  }

  String _normalizeDate(dynamic value) {
    final text = _asString(value);
    if (text.isEmpty) {
      return '';
    }
    return text.length >= 10 ? text.substring(0, 10) : text;
  }

  double? _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }

  String _formatAmount(dynamic value, {String unit = 'g'}) {
    final parsed = _asDouble(value);
    if (parsed == null) {
      return '';
    }
    final text = parsed % 1 == 0
        ? parsed.toInt().toString()
        : parsed.toStringAsFixed(1);
    return '$text$unit';
  }

  String _formatPercent(dynamic value) {
    final parsed = _asDouble(value);
    if (parsed == null) {
      return '';
    }
    final text = parsed % 1 == 0
        ? parsed.toInt().toString()
        : parsed.toStringAsFixed(1);
    return '$text%';
  }

  Map<String, dynamic>? _extractPlanMap(Map<String, dynamic> body) {
    final data = body['data'];

    if (data is Map<String, dynamic>) {
      if (data['foodplan'] is Map<String, dynamic>) {
        return data['foodplan'] as Map<String, dynamic>;
      }
      if (data['food_plan'] is Map<String, dynamic>) {
        return data['food_plan'] as Map<String, dynamic>;
      }
      if (data['plan'] is Map<String, dynamic>) {
        return data['plan'] as Map<String, dynamic>;
      }
      if (data['current_plan'] is Map<String, dynamic>) {
        return data['current_plan'] as Map<String, dynamic>;
      }

      final plans = _asMapList(
        data['plans'] ??
            data['foodplans'] ??
            data['food_plans'] ??
            data['items'],
      );
      if (plans.isNotEmpty) {
        return plans.first;
      }

      return data;
    }

    if (data is List) {
      final maps = data.whereType<Map<String, dynamic>>().toList();
      if (maps.isNotEmpty) {
        return maps.first;
      }
    }

    if (body['foodplan'] is Map<String, dynamic>) {
      return body['foodplan'] as Map<String, dynamic>;
    }

    return _asMap(body);
  }

  List<Map<String, dynamic>> _extractMealItemMaps(
    Map<String, dynamic> body,
    Map<String, dynamic> planMap,
  ) {
    List<Map<String, dynamic>> pick(dynamic value) => _asMapList(value);

    final fromPlan = pick(planMap['meal_items'])
        .followedBy(pick(planMap['foods']))
        .followedBy(pick(planMap['items']))
        .toList();
    if (fromPlan.isNotEmpty) {
      return fromPlan;
    }

    final data = _asMap(body['data']);
    if (data != null) {
      final fromData = pick(data['meal_items'])
          .followedBy(pick(data['foods']))
          .followedBy(pick(data['items']))
          .toList();
      if (fromData.isNotEmpty) {
        return fromData;
      }
    }

    return const <Map<String, dynamic>>[];
  }

  List<FoodMealItem> _parseMealItems(
    Map<String, dynamic> body,
    Map<String, dynamic> planMap,
  ) {
    final maps = _extractMealItemMaps(body, planMap);
    return maps
        .map((item) {
          final name = _asString(
            item['name'] ?? item['title'] ?? item['food_name'],
          );
          final subtitle = _asString(
            item['subtitle'] ??
                item['type'] ??
                item['category'] ??
                item['description'],
          );

          final amount = _formatAmount(
            item['amount'] ?? item['gram'] ?? item['grams'] ?? item['weight'],
          );
          final percent = _formatPercent(
            item['percent'] ??
                item['percentage'] ??
                item['ratio'] ??
                item['portion_percent'],
          );

          return FoodMealItem(
            name: name,
            subtitle: subtitle,
            amount: amount,
            percent: percent,
          );
        })
        .where((item) => item.name.isNotEmpty)
        .toList();
  }

  FoodMacroSummary? _parseMacros(
    Map<String, dynamic> body,
    Map<String, dynamic> planMap,
  ) {
    final data = _asMap(body['data']);
    final macroMap =
        _asMap(planMap['macros']) ??
        _asMap(data?['macros']) ??
        _asMap(planMap['nutrition']) ??
        _asMap(data?['nutrition']);

    final protein = _formatAmount(
      macroMap?['protein'] ?? planMap['protein'] ?? data?['protein'],
    );
    final fat = _formatAmount(
      macroMap?['fat'] ?? planMap['fat'] ?? data?['fat'],
    );

    final kcalRaw = _asDouble(
      macroMap?['kcal'] ??
          macroMap?['energy'] ??
          planMap['kcal'] ??
          planMap['energy'] ??
          data?['kcal'] ??
          data?['energy'],
    );
    final kcal = kcalRaw == null
        ? ''
        : (kcalRaw % 1 == 0
              ? kcalRaw.toInt().toString()
              : kcalRaw.toStringAsFixed(1));

    if (protein.isEmpty && fat.isEmpty && kcal.isEmpty) {
      return null;
    }

    return FoodMacroSummary(protein: protein, fat: fat, kcal: kcal);
  }

  List<String> _parsePerformanceNotes(
    Map<String, dynamic> body,
    Map<String, dynamic> planMap,
  ) {
    final data = _asMap(body['data']);
    final candidates = <dynamic>[
      planMap['performance_notes'],
      data?['performance_notes'],
      planMap['notes'],
      data?['notes'],
      planMap['analysis'],
      data?['analysis'],
    ];

    final notes = <String>[];
    for (final candidate in candidates) {
      if (candidate is List) {
        for (final item in candidate) {
          final text = _asString(item);
          if (text.isNotEmpty) {
            notes.add(text);
          }
        }
      } else if (candidate is String) {
        final text = candidate.trim();
        if (text.isNotEmpty) {
          notes.add(text);
        }
      }
    }

    return notes;
  }

  List<Map<String, dynamic>> _extractFoodsList(Map<String, dynamic> body) {
    final direct = _asMapList(body['foods']);
    if (direct.isNotEmpty) {
      return direct;
    }

    final directSingular = _asMapList(body['food']);
    if (directSingular.isNotEmpty) {
      return directSingular;
    }

    if (body['food'] is Map<String, dynamic>) {
      return [body['food'] as Map<String, dynamic>];
    }

    final data = body['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      final nested = _asMapList(data['foods']);
      if (nested.isNotEmpty) {
        return nested;
      }

      final nestedSingular = _asMapList(data['food']);
      if (nestedSingular.isNotEmpty) {
        return nestedSingular;
      }

      if (data['food'] is Map<String, dynamic>) {
        return [data['food'] as Map<String, dynamic>];
      }

      final items = _asMapList(data['items']);
      if (items.isNotEmpty) {
        return items;
      }

      final rows = _asMapList(data['rows']);
      if (rows.isNotEmpty) {
        return rows;
      }

      final list = _asMapList(data['list']);
      if (list.isNotEmpty) {
        return list;
      }

      final nestedData = data['data'];
      if (nestedData is List) {
        final fromNestedData = nestedData
            .whereType<Map<String, dynamic>>()
            .toList();
        if (fromNestedData.isNotEmpty) {
          return fromNestedData;
        }
      }

      if (nestedData is Map<String, dynamic>) {
        final nestedFoods = _asMapList(nestedData['foods']);
        if (nestedFoods.isNotEmpty) {
          return nestedFoods;
        }

        final nestedFoodsSingular = _asMapList(nestedData['food']);
        if (nestedFoodsSingular.isNotEmpty) {
          return nestedFoodsSingular;
        }
      }
    }

    return _asMapList(body['items']);
  }

  List<Map<String, dynamic>> _extractFoodsFromResponse(
    Map<String, dynamic> body,
  ) {
    final data = _asMap(body['data']);
    final foods = _asMapList(data?['foods']);
    if (foods.isNotEmpty) {
      return foods;
    }

    return _extractFoodsList(body);
  }

  int _resolveFoodType(Map<String, dynamic> item) {
    final raw = _pickValue(item, const [
      'food_type',
      'foodType',
      'type',
      'Type',
      'food_type_id',
      'foodTypeId',
      'foodtype',
      'FoodType',
    ]);
    final text = _asString(raw).toLowerCase();
    if (text.contains('dry') || text.contains('แห้ง')) {
      return 0;
    }
    if (text.contains('wet') || text.contains('เปียก')) {
      return 1;
    }
    if (text.contains('treat')) {
      return 2;
    }
    if (text.contains('supplement') || text.contains('เสริม')) {
      return 3;
    }

    final asInt = _asInt(raw);
    if (asInt != null) {
      if (asInt >= 0 && asInt <= 3) {
        return asInt;
      }
      if (asInt >= 1 && asInt <= 4) {
        return asInt - 1;
      }
    }
    return -1;
  }

  FoodInventoryCounts _buildCountsFromFoods(List<Map<String, dynamic>> foods) {
    var dry = 0;
    var wet = 0;
    var treats = 0;
    var supplements = 0;

    final numericTypes = foods
        .map(
          (item) => _asInt(
            _pickValue(item, const [
              'food_type',
              'foodType',
              'type',
              'Type',
              'food_type_id',
              'foodTypeId',
              'foodtype',
              'FoodType',
            ]),
          ),
        )
        .whereType<int>()
        .toList();
    final hasZeroBasedType = numericTypes.contains(0);
    final looksOneBasedType =
        !hasZeroBasedType &&
        numericTypes.isNotEmpty &&
        numericTypes.every((value) => value >= 1 && value <= 4);

    for (final item in foods) {
      var resolvedType = _resolveFoodType(item);

      if (looksOneBasedType && resolvedType >= 1 && resolvedType <= 3) {
        final rawType = _asInt(
          _pickValue(item, const [
            'food_type',
            'foodType',
            'type',
            'Type',
            'food_type_id',
            'foodTypeId',
            'foodtype',
            'FoodType',
          ]),
        );
        if (rawType != null && rawType >= 1 && rawType <= 4) {
          resolvedType = rawType - 1;
        }
      }

      switch (resolvedType) {
        case 0:
          dry += 1;
          break;
        case 1:
          wet += 1;
          break;
        case 2:
          treats += 1;
          break;
        case 3:
          supplements += 1;
          break;
      }
    }

    return FoodInventoryCounts(
      dry: dry,
      wet: wet,
      treats: treats,
      supplements: supplements,
    );
  }

  String _toAbsoluteImageUrl(String rawPath) {
    final path = rawPath.trim();
    if (path.isEmpty) {
      return '';
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

  FoodItemSummary _mapFoodItem(Map<String, dynamic> source) {
    final id =
        _asInt(source['id'] ?? source['food_id'] ?? source['foodId']) ?? 0;
    final foodType = _resolveFoodType(source);
    final name = _asString(
      source['name'] ?? source['food_name'] ?? source['title'],
    );
    final brand = _asString(
      source['brand'] ?? source['brand_name'] ?? source['manufacturer'],
    );

    final imageUrl = _toAbsoluteImageUrl(
      _asString(source['image_url'] ?? source['image_path'] ?? source['image']),
    );

    final stockCount =
        _asInt(
          source['stock_count'] ?? source['stock'] ?? source['quantity'],
        ) ??
        0;

    final protein =
        _asDouble(
          source['protein'] ??
              source['protein_percent'] ??
              source['protein_pct'],
        ) ??
        0;
    final fat =
        _asDouble(
          source['fat'] ?? source['fat_percent'] ?? source['fat_pct'],
        ) ??
        0;
    final moisture =
        _asDouble(
          source['moist'] ??
              source['moisture'] ??
              source['moisture_percent'] ??
              source['water'],
        ) ??
        0;
    final energy =
        _asDouble(
          source['energy'] ?? source['kcal'] ?? source['energy_kcal'],
        ) ??
        0;
    final gramsPerCup = _asDouble(
      source['grams_per_cup'] ??
          source['gram_per_cup'] ??
          source['g_per_cup'] ??
          source['gramsPerCup'],
    );

    return FoodItemSummary(
      id: id,
      foodType: foodType,
      name: name,
      brand: brand,
      imageUrl: imageUrl,
      stockCount: stockCount,
      protein: protein,
      fat: fat,
      moisture: moisture,
      energy: energy,
      gramsPerCup: gramsPerCup,
    );
  }

  List<Uri> _candidateFoodTypeUris(int foodType) {
    final candidates = <Uri>[];
    final seen = <String>{};

    void addUri(Uri uri) {
      final key = uri.toString();
      if (seen.add(key)) {
        candidates.add(uri);
      }
    }

    void addTypeUris(int typeValue) {
      addUri(Uri.parse('${AppConfig.apiBaseUrl}/foods/$typeValue'));
      addUri(Uri.parse('${AppConfig.apiBaseUrl}/foods/$typeValue/'));
      addUri(Uri.parse('${AppConfig.apiBaseUrl}/food/$typeValue'));
      addUri(Uri.parse('${AppConfig.apiBaseUrl}/food/$typeValue/'));
      addUri(Uri.parse('${AppConfig.apiBaseUrl}/food/type/$typeValue'));
      addUri(Uri.parse('${AppConfig.apiBaseUrl}/food/type/$typeValue/'));

      final baseFoods = Uri.parse('${AppConfig.apiBaseUrl}/foods');
      addUri(baseFoods.replace(queryParameters: {'food_type': '$typeValue'}));
      addUri(baseFoods.replace(queryParameters: {'type': '$typeValue'}));
      addUri(baseFoods.replace(queryParameters: {'foodType': '$typeValue'}));

      final baseFood = Uri.parse('${AppConfig.apiBaseUrl}/food');
      addUri(baseFood.replace(queryParameters: {'food_type': '$typeValue'}));
      addUri(baseFood.replace(queryParameters: {'type': '$typeValue'}));
      addUri(baseFood.replace(queryParameters: {'foodType': '$typeValue'}));
    }

    addTypeUris(foodType);

    final oneBasedType = foodType + 1;
    if (oneBasedType != foodType) {
      addTypeUris(oneBasedType);
    }

    return candidates;
  }

  Future<(http.Response, Map<String, dynamic>)> _requestFoodsByType(
    String accessToken,
    int foodType,
  ) async {
    final uris = _candidateFoodTypeUris(foodType);
    Exception? lastError;

    for (final uri in uris) {
      late final http.Response response;
      try {
        response = await _client
            .get(uri, headers: _buildHeaders(accessToken))
            .timeout(const Duration(seconds: 15));
      } on TimeoutException {
        _debugFoodApiLog('GET $uri -> timeout');
        throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
      } on SocketException {
        _debugFoodApiLog('GET $uri -> socket error');
        throw Exception(
          'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบ backend',
        );
      }

      final body = _decodeJsonMap(response);
      _debugFoodApiLog(
        'GET $uri -> ${response.statusCode}, body=${_truncateForLog(response.body)}',
      );
      if (_isSuccessStatus(response.statusCode)) {
        return (response, body);
      }

      if (_isNoDataStatus(response.statusCode) &&
          _looksLikeNoDataMessage(body)) {
        return (response, body);
      }

      lastError = _buildHttpException(response, body);

      if (response.statusCode != 404) {
        break;
      }
    }

    throw lastError ?? Exception('ไม่สามารถดึงข้อมูลอาหารได้');
  }

  Future<List<FoodItemSummary>> fetchFoodItemsByType({
    required String accessToken,
    required int foodType,
  }) async {
    _debugFoodApiLog('fetchFoodItemsByType(type=$foodType)');
    final (response, body) = await _requestFoodsByType(accessToken, foodType);
    if (!_isSuccessStatus(response.statusCode)) {
      if (_isNoDataStatus(response.statusCode) &&
          _looksLikeNoDataMessage(body)) {
        _debugFoodApiLog('type=$foodType -> no data');
        return <FoodItemSummary>[];
      }
      throw _buildHttpException(response, body);
    }

    final foods = _extractFoodsFromResponse(body);
    _debugFoodApiLog('type=$foodType -> extracted foods=${foods.length}');

    return foods
        .map(_mapFoodItem)
        .where((item) => item.id > 0 || item.name.isNotEmpty)
        .toList();
  }

  Future<void> createFood({
    required String accessToken,
    required CreateFoodPayload payload,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/food/');

    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: _buildHeaders(accessToken),
            body: jsonEncode(payload.toJson()),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบ backend');
    }

    final body = _decodeJsonMap(response);
    if (!_isSuccessStatus(response.statusCode)) {
      if (_isNoDataStatus(response.statusCode) &&
          _looksLikeNoDataMessage(body)) {
        return;
      }
      throw _buildHttpException(response, body);
    }
  }

  Future<void> updateFood({
    required String accessToken,
    required int foodId,
    required CreateFoodPayload payload,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/food/');

    final requestBody = <String, dynamic>{
      'id': foodId,
      'food_id': foodId,
      ...payload.toJson(),
    };

    late final http.Response response;
    try {
      response = await _client
          .patch(
            uri,
            headers: _buildHeaders(accessToken),
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบ backend');
    }

    final body = _decodeJsonMap(response);
    if (!_isSuccessStatus(response.statusCode)) {
      if (_isNoDataStatus(response.statusCode) &&
          _looksLikeNoDataMessage(body)) {
        return;
      }
      throw _buildHttpException(response, body);
    }
  }

  Future<void> deleteFood({
    required String accessToken,
    required int foodId,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/food/$foodId');

    late final http.Response response;
    try {
      response = await _client
          .delete(uri, headers: _buildHeaders(accessToken))
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบ backend');
    }

    final body = _decodeJsonMap(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw _buildHttpException(response, body);
    }
  }

  double? _normalizeNutritionValue(double? value) {
    if (value == null || value < 0) {
      return null;
    }
    return value;
  }

  Future<OcrNutritionResult> requestNutritionOcr({
    required String accessToken,
    required File imageFile,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/ocr/request');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_buildAuthHeaders(accessToken))
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    late final http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw Exception('OCR ใช้เวลานานเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception(
        'ไม่สามารถเชื่อมต่อ OCR service ได้ กรุณาลองใหม่อีกครั้ง',
      );
    }

    final response = await http.Response.fromStream(streamed);
    final body = _decodeJsonMap(response);

    if (!_isSuccessStatus(response.statusCode)) {
      throw _buildHttpException(response, body);
    }

    final data = _asMap(body['data']) ?? body;

    return OcrNutritionResult(
      energy: _normalizeNutritionValue(
        _asDouble(data['energy'] ?? data['kcal'] ?? data['energy_kcal']),
      ),
      protein: _normalizeNutritionValue(_asDouble(data['protein'])),
      fat: _normalizeNutritionValue(_asDouble(data['fat'])),
      moisture: _normalizeNutritionValue(_asDouble(data['moisture'])),
    );
  }

  Future<List<Map<String, dynamic>>> fetchFoods({
    required String accessToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/foods');

    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: _buildHeaders(accessToken))
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบ backend');
    }

    final body = _decodeJsonMap(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw _buildHttpException(response, body);
    }

    return _extractFoodsFromResponse(body);
  }

  Future<int> fetchFoodCountByType({
    required String accessToken,
    required int foodType,
  }) async {
    _debugFoodApiLog('fetchFoodCountByType(type=$foodType)');
    final (response, body) = await _requestFoodsByType(accessToken, foodType);
    if (!_isSuccessStatus(response.statusCode)) {
      if (_isNoDataStatus(response.statusCode) &&
          _looksLikeNoDataMessage(body)) {
        _debugFoodApiLog('count type=$foodType -> no data');
        return 0;
      }
      throw _buildHttpException(response, body);
    }

    final data = _asMap(body['data']);
    final count = _asInt(
      body['count'] ??
          body['total'] ??
          body['length'] ??
          data?['count'] ??
          data?['total'] ??
          data?['length'],
    );
    if (count != null) {
      _debugFoodApiLog('count type=$foodType -> $count (from count/total)');
      return count;
    }

    final foods = _extractFoodsFromResponse(body);
    _debugFoodApiLog(
      'count type=$foodType -> ${foods.length} (from foods list)',
    );
    return foods.length;
  }

  Future<FoodInventoryCounts> fetchFoodInventoryCounts({
    required String accessToken,
  }) async {
    Future<int> safeCount(int type) async {
      try {
        return await fetchFoodCountByType(
          accessToken: accessToken,
          foodType: type,
        );
      } catch (_) {
        return 0;
      }
    }

    final counts = await Future.wait<int>([
      safeCount(0),
      safeCount(1),
      safeCount(2),
      safeCount(3),
    ]);

    _debugFoodApiLog(
      'inventory counts => dry=${counts[0]}, wet=${counts[1]}, treats=${counts[2]}, supplements=${counts[3]}',
    );

    return FoodInventoryCounts(
      dry: counts[0],
      wet: counts[1],
      treats: counts[2],
      supplements: counts[3],
    );
  }

  FoodPlanSummary? _buildFoodPlanSummaryFromBody(Map<String, dynamic> body) {
    final planMap = _extractPlanMap(body);
    if (planMap == null || planMap.isEmpty) {
      return null;
    }

    final planName = _asString(
      planMap['name'] ?? planMap['plan_name'] ?? planMap['food_plan_name'],
    );
    final startDate = _normalizeDate(
      planMap['start_date'] ?? planMap['started_at'] ?? planMap['created_at'],
    );

    final mealItems = _parseMealItems(body, planMap);
    final macros = _parseMacros(body, planMap);
    final performanceNotes = _parsePerformanceNotes(body, planMap);

    if (planName.isEmpty &&
        startDate.isEmpty &&
        mealItems.isEmpty &&
        macros == null &&
        performanceNotes.isEmpty) {
      return null;
    }

    return FoodPlanSummary(
      planName: planName,
      startDate: startDate,
      mealItems: mealItems,
      macros: macros,
      performanceNotes: performanceNotes,
    );
  }

  Future<Map<String, dynamic>> _postFoodPlan({
    required String accessToken,
    required String path,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');

    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: _buildHeaders(accessToken),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบ backend');
    }

    final body = _decodeJsonMap(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw _buildHttpException(response, body);
    }

    return body;
  }

  Future<FoodPlanSummary?> calculateFoodPlan({
    required String accessToken,
    required String name,
    required int petId,
    required int unit,
    required List<Map<String, dynamic>> foods,
  }) async {
    final body = await _postFoodPlan(
      accessToken: accessToken,
      path: '/foodplan/calculate',
      payload: <String, dynamic>{
        'name': name,
        'pet_id': petId,
        'unit': unit,
        'foods': foods,
      },
    );

    return _buildFoodPlanSummaryFromBody(body);
  }

  Future<FoodPlanSummary?> createFoodPlan({
    required String accessToken,
    required String name,
    required int petId,
    required int unit,
    required List<Map<String, dynamic>> foods,
  }) async {
    final body = await _postFoodPlan(
      accessToken: accessToken,
      path: '/foodplan',
      payload: <String, dynamic>{
        'name': name,
        'pet_id': petId,
        'unit': unit,
        'foods': foods,
      },
    );

    return _buildFoodPlanSummaryFromBody(body);
  }

  Future<FoodPlanSummary?> fetchFoodPlan({
    required String accessToken,
    required int petId,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/foodplan/$petId');

    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: _buildHeaders(accessToken))
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบ backend');
    }

    final body = _decodeJsonMap(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw _buildHttpException(response, body);
    }

    return _buildFoodPlanSummaryFromBody(body);
  }
}
