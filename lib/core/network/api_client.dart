import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../error/exceptions.dart';

/// Thin wrapper over `package:http` that centralises timeout handling, JSON
/// decoding and the exception taxonomy used by the datasources.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> postJson(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(url),
            headers: ApiConstants.jsonHeaders,
            body: jsonEncode(body ?? const {}),
          )
          .timeout(ApiConstants.receiveTimeout);
    } on TimeoutException {
      throw const NetworkException('The request timed out. Please try again.');
    } catch (_) {
      throw const NetworkException();
    }

    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ParsingException();
    }

    final success = json['success'] == true;
    final is2xx = response.statusCode >= 200 && response.statusCode < 300;

    if (is2xx && success) return json;

    // API error contract: { success, message, error: { code, details } }
    final error = json['error'] as Map<String, dynamic>?;
    final message = (json['message'] as String?) ??
        (error?['details'] as String?) ??
        'Request failed (${response.statusCode}).';
    throw ServerException(message, code: error?['code'] as String?);
  }

  void close() => _client.close();
}
