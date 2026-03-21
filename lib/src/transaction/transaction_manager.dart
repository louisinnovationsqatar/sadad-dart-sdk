// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import '../auth/authenticator.dart';
import '../http/http_client.dart';
import '../sadad_config.dart';

/// Retrieves SADAD transaction details.
class TransactionManager {
  final SadadConfig _config;
  final HttpClientInterface _httpClient;
  final Authenticator _authenticator;

  TransactionManager(this._config, this._httpClient, this._authenticator);

  /// Retrieves transaction details by [transactionNumber].
  ///
  /// Returns a map with `success` and `transaction` on success,
  /// or `success: false` and `error` on failure.
  Future<Map<String, dynamic>> getTransaction(
    String transactionNumber,
  ) async {
    try {
      final token = await _authenticator.getAccessToken();

      final response = await _httpClient.get(
        '${_config.getApiBaseUrl()}/transactions/getTransaction',
        params: {'transactionno': transactionNumber},
        headers: {'Authorization': 'Bearer $token'},
      );

      return {
        'success': true,
        'transaction': response,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
