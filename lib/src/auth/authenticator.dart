// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import '../errors/authentication_exception.dart';
import '../http/http_client.dart';
import '../sadad_config.dart';

/// Authenticates with the SADAD API and caches the access token for 1 hour.
class Authenticator {
  static const Duration _tokenTtl = Duration(hours: 1);

  final SadadConfig _config;
  final HttpClientInterface _httpClient;

  String? _accessToken;
  DateTime? _tokenExpiry;

  Authenticator(this._config, this._httpClient);

  /// Returns a valid access token, logging in if the cached token has expired.
  ///
  /// Throws [AuthenticationException] if authentication fails.
  Future<String> getAccessToken() async {
    final expiry = _tokenExpiry;
    if (_accessToken != null &&
        expiry != null &&
        DateTime.now().isBefore(expiry)) {
      return _accessToken!;
    }
    return login();
  }

  /// Posts credentials to `/userbusinesses/login` and caches the token.
  ///
  /// Throws [AuthenticationException] if the response contains no `accessToken`.
  Future<String> login() async {
    try {
      final response = await _httpClient.post(
        '${_config.getApiBaseUrl()}/userbusinesses/login',
        data: {
          'sadadId': int.parse(_config.merchantId),
          'secretKey': _config.secretKey,
          'domain': _config.website,
        },
      );

      final token = response['accessToken']?.toString();
      if (token == null || token.isEmpty) {
        throw const AuthenticationException('No access token in response');
      }

      _accessToken = token;
      _tokenExpiry = DateTime.now().add(_tokenTtl);

      return _accessToken!;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AuthenticationException(
        'Authentication failed: $e',
        cause: e,
      );
    }
  }

  /// Clears the cached token, forcing a fresh login on the next call.
  void clearToken() {
    _accessToken = null;
    _tokenExpiry = null;
  }
}
