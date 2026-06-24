import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/class_item.dart';

class ClassService {
  static const String _upperBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _lowerBaseUrl = String.fromEnvironment(
    'baseUrl',
    defaultValue: '',
  );

  static const String _upperAccessToken = String.fromEnvironment(
    'ACCESS_TOKEN',
    defaultValue: '',
  );
  static const String _lowerAccessToken = String.fromEnvironment(
    'access_token',
    defaultValue: '',
  );

  final String baseUrl;
  final String accessToken;
  final http.Client _client;

  ClassService({String? baseUrl, String? accessToken, http.Client? client})
    : baseUrl = _resolveBaseUrl(baseUrl),
      accessToken = _resolveAccessToken(accessToken),
      _client = client ?? http.Client();

  static String _resolveBaseUrl(String? value) {
    final injectedValue = value?.trim();
    if (injectedValue != null && injectedValue.isNotEmpty) {
      return injectedValue;
    }

    if (_upperBaseUrl.isNotEmpty) return _upperBaseUrl;
    if (_lowerBaseUrl.isNotEmpty) return _lowerBaseUrl;

    // Android emulators reach the host machine through 10.0.2.2.
    return 'http://10.0.2.2:5000';
  }

  static String _resolveAccessToken(String? value) {
    final injectedValue = value?.trim();
    if (injectedValue != null && injectedValue.isNotEmpty) {
      return injectedValue;
    }

    if (_upperAccessToken.isNotEmpty) return _upperAccessToken;
    return _lowerAccessToken;
  }

  Future<List<ClassItem>> getMyClasses() async {
    if (accessToken.trim().isEmpty) {
      throw const ClassServiceException(
        'Missing access token. Log in first, or run Flutter with --dart-define=access_token=<token>.',
      );
    }

    final uri = Uri.parse('$baseUrl/api/v1/classes/my-classes');
    final response = await _client
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] == true;
    if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
      throw ClassServiceException(
        body['message'] as String? ?? 'Failed to load classes.',
      );
    }

    final data = body['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(ClassItem.fromClassListJson)
        .toList();
  }
}

class ClassServiceException implements Exception {
  final String message;

  const ClassServiceException(this.message);

  @override
  String toString() => message;
}
