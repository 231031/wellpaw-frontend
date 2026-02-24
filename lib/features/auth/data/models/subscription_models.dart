class SubscriptionPlan {
  final String id;
  final String name;
  final List<String> features;
  final double amount;
  final String currency;
  final String interval;
  final int intervalCount;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.features,
    required this.amount,
    required this.currency,
    required this.interval,
    required this.intervalCount,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    return SubscriptionPlan(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      features: rawFeatures is List
          ? rawFeatures.map((item) => item.toString()).toList()
          : <String>[],
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'THB',
      interval: json['interval']?.toString() ?? 'month',
      intervalCount: json['interval_count'] is int
          ? json['interval_count'] as int
          : int.tryParse(json['interval_count']?.toString() ?? '') ?? 1,
    );
  }

  String get priceLabel {
    final formatted = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    if (amount == 0) {
      return 'ฟรี';
    }
    return formatted;
  }

  String get intervalLabel {
    if (amount == 0) {
      return 'ทดลองใช้ฟรี';
    }
    if (intervalCount > 1) {
      return 'ทุก $intervalCount ${_intervalText(interval)}';
    }
    return 'ต่อ${_intervalText(interval)}';
  }

  String get priceDetail {
    if (amount == 0) {
      return '7 วันแรก';
    }
    return '${_currencyText(currency)}/${_intervalText(interval)}';
  }

  String _intervalText(String value) {
    switch (value.toLowerCase()) {
      case 'year':
        return 'ปี';
      case 'month':
        return 'เดือน';
      case 'week':
        return 'สัปดาห์';
      case 'day':
        return 'วัน';
      default:
        return value;
    }
  }

  String _currencyText(String value) {
    switch (value.toLowerCase()) {
      case 'thb':
        return 'บาท';
      default:
        return value.toUpperCase();
    }
  }
}

class StartSubscriptionResult {
  final String clientSecret;

  const StartSubscriptionResult({required this.clientSecret});

  factory StartSubscriptionResult.fromJson(Map<String, dynamic> json) {
    return StartSubscriptionResult(
      clientSecret: json['client_secret']?.toString() ?? '',
    );
  }
}
