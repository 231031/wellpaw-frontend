import 'package:flutter/foundation.dart';

class AppConfig {
  static const _apiBaseUrlDefault = 'http://localhost:50001/api';
  static const _apiBaseUrlAndroidEmulator = 'http://10.0.2.2:50001/api';

  static String get apiBaseUrl {
    if (kIsWeb) {
      return _apiBaseUrlDefault;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _apiBaseUrlAndroidEmulator;
      default:
        return _apiBaseUrlDefault;
    }
  }

  // TODO: Replace with your OAuth client IDs once generated.
  static const googleWebClientId =
      '312129132906-mbcecj8cuu9b8q9fil5oe12r6o86jhi0.apps.googleusercontent.com';
  static const googleIosClientId =
      '312129132906-bh7n813gprh3k79e5af4kd5c195chnoi.apps.googleusercontent.com';

  // Use publishable key only (pk_*). Never commit secret keys (sk_*).
  static const stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';

  static bool get hasValidApiBaseUrl {
    return apiBaseUrl.isNotEmpty && !apiBaseUrl.contains('your-api-domain.com');
  }

  static bool get hasValidGoogleWebClientId {
    return googleWebClientId.isNotEmpty &&
        !googleWebClientId.startsWith('YOUR_');
  }

  static bool get hasValidGoogleIosClientId {
    return googleIosClientId.isNotEmpty &&
        !googleIosClientId.startsWith('YOUR_');
  }

  static bool get hasValidStripePublishableKey {
    return stripePublishableKey.isNotEmpty &&
        !stripePublishableKey.contains('YOUR_STRIPE_PUBLISHABLE_KEY');
  }
}
