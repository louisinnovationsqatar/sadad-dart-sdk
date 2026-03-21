// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/sadad_exception.dart';

/// Abstract interface for the HTTP client used by the SADAD SDK.
///
/// Implement this to provide a custom HTTP client (e.g. for testing).
abstract class HttpClientInterface {
  /// Sends a POST request and returns the decoded JSON response body.
  ///
  /// [url] must be a fully-qualified URL.
  /// [data] is JSON-encoded as the request body.
  /// [headers] are additional HTTP headers to include.
  ///
  /// Throws [SadadException] on HTTP or parse errors.
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic> data = const {},
    Map<String, String> headers = const {},
  });

  /// Sends a GET request and returns the decoded JSON response body.
  ///
  /// [url] must be a fully-qualified URL.
  /// [params] are appended as query string parameters.
  /// [headers] are additional HTTP headers to include.
  ///
  /// Throws [SadadException] on HTTP or parse errors.
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic> params = const {},
    Map<String, String> headers = const {},
  });
}

/// Default [HttpClientInterface] implementation using the `http` package.
class DartHttpClient implements HttpClientInterface {
  static const int _defaultTimeoutSeconds = 30;

  final http.Client _client;

  DartHttpClient({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic> data = const {},
    Map<String, String> headers = const {},
  }) async {
    try {
      final mergedHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...headers,
      };

      final response = await _client
          .post(
            Uri.parse(url),
            headers: mergedHeaders,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: _defaultTimeoutSeconds));

      return _parseResponse(response);
    } on SadadException {
      rethrow;
    } catch (e) {
      throw SadadException(
        'HTTP POST request failed: $e',
        errorCode: 'HTTP_ERROR',
        cause: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic> params = const {},
    Map<String, String> headers = const {},
  }) async {
    try {
      final mergedHeaders = {
        'Accept': 'application/json',
        ...headers,
      };

      final uri = params.isEmpty
          ? Uri.parse(url)
          : Uri.parse(url).replace(
              queryParameters:
                  params.map((k, v) => MapEntry(k, v.toString())),
            );

      final response = await _client
          .get(uri, headers: mergedHeaders)
          .timeout(const Duration(seconds: _defaultTimeoutSeconds));

      return _parseResponse(response);
    } on SadadException {
      rethrow;
    } catch (e) {
      throw SadadException(
        'HTTP GET request failed: $e',
        errorCode: 'HTTP_ERROR',
        cause: e,
      );
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    } catch (e) {
      throw SadadException(
        'Failed to parse JSON response: ${response.body}',
        errorCode: 'PARSE_ERROR',
        httpStatus: response.statusCode,
        cause: e,
      );
    }
  }
}
