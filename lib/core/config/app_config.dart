class AppConfig {
  static const apiBaseUrl = 'http://localhost:50001/api';

  // TODO: Replace with your OAuth client IDs once generated.
  static const googleWebClientId =
      '312129132906-mbcecj8cuu9b8q9fil5oe12r6o86jhi0.apps.googleusercontent.com';
  static const googleIosClientId =
      '312129132906-bh7n813gprh3k79e5af4kd5c195chnoi.apps.googleusercontent.com';

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
}
