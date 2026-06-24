import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/squarle_join_result.dart';
import '../models/squarle_status.dart';

class SquarleService {
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

  SquarleService({String? baseUrl, String? accessToken, http.Client? client})
      : baseUrl = _resolveBaseUrl(baseUrl),
        accessToken = _resolveAccessToken(accessToken),
        _client = client ?? http.Client();

  Future<SquarleStatus> getStatus(String classId) async {
    final body = await _request(
      Uri.parse('$baseUrl/api/v1/squarle/$classId/status'),
      method: 'GET',
    );
    return SquarleStatus.fromJson(body);
  }

  Future<SquarleJoinResult> joinSquarle(String classId) async {
    final body = await _request(
      Uri.parse('$baseUrl/api/v1/squarle/$classId/join'),
      method: 'POST',
    );
    return SquarleJoinResult.fromJson(body);
  }

  Future<String> leaveSquarle(String sessionId) async {
    final body = await _request(
      Uri.parse('$baseUrl/api/v1/squarle/$sessionId/leave'),
      method: 'POST',
    );
    return body['message'] as String? ?? 'Left squarle';
  }

  Future<Map<String, dynamic>> _request(Uri uri, {required String method}) async {
    if (accessToken.trim().isEmpty) {
      throw const SquarleServiceException(
        'Missing access token. Run Flutter with --dart-define=access_token=<token>.',
      );
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final response = method == 'POST'
        ? await _client.post(uri, headers: headers).timeout(const Duration(seconds: 15))
        : await _client.get(uri, headers: headers).timeout(const Duration(seconds: 15));

    final decoded = jsonDecode(response.body);
    final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    final success = body['success'] == true;

    if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
      throw SquarleServiceException(
        body['message'] as String? ?? 'Unable to connect to squarle.',
      );
    }

    return body;
  }

  static String _resolveBaseUrl(String? value) {
    final injectedValue = value?.trim();
    if (injectedValue != null && injectedValue.isNotEmpty) return injectedValue;
    if (_upperBaseUrl.isNotEmpty) return _upperBaseUrl;
    if (_lowerBaseUrl.isNotEmpty) return _lowerBaseUrl;
    return 'http://10.0.2.2:5000';
  }

  static String _resolveAccessToken(String? value) {
    final injectedValue = value?.trim();
    if (injectedValue != null && injectedValue.isNotEmpty) return injectedValue;
    if (_upperAccessToken.isNotEmpty) return _upperAccessToken;
    return _lowerAccessToken;
  }
}

class SquarleServiceException implements Exception {
  final String message;

  const SquarleServiceException(this.message);

  @override
  String toString() => message;
}
