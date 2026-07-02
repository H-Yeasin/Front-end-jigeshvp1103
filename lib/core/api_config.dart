import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _upperBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _lowerBaseUrl = String.fromEnvironment(
    'baseUrl',
    defaultValue: '',
  );

  static String resolveBaseUrl(String? value) {
    final injectedValue = value?.trim();
    if (injectedValue != null && injectedValue.isNotEmpty) {
      return injectedValue;
    }

    if (_upperBaseUrl.isNotEmpty) return _upperBaseUrl;
    if (_lowerBaseUrl.isNotEmpty) return _lowerBaseUrl;

    return kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
  }
}
