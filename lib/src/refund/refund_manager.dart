// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import '../auth/authenticator.dart';
import '../errors/refund_exception.dart';
import '../http/http_client.dart';
import '../sadad_config.dart';
import '../transaction/transaction_manager.dart';

/// Issues full refunds for SADAD transactions with eligibility validation.
class RefundManager {
  static const int _statusSuccess = 3;

  /// Maximum age of a transaction before refund is disallowed (90 days).
  static const Duration _maxRefundAge = Duration(days: 90);

  final SadadConfig _config;
  final HttpClientInterface _httpClient;
  final Authenticator _authenticator;
  final TransactionManager _transactionManager;

  RefundManager(
    this._config,
    this._httpClient,
    this._authenticator,
    this._transactionManager,
  );

  /// Issues a full refund for [transactionNumber].
  ///
  /// SADAD supports **full refunds only** — no partial amount is accepted.
  ///
  /// Validation checks (in order):
  ///   1. Transaction must be found.
  ///   2. Transaction status must be 3 (Success).
  ///   3. Transaction must be within 3 months (90 days) of the original date.
  ///   4. Transaction must not already be refunded.
  ///
  /// Returns a map with `success` and `refund_details` on success,
  /// or `success: false` and `error` if the HTTP call fails.
  ///
  /// Throws [RefundException] when eligibility validation fails.
  Future<Map<String, dynamic>> refund(String transactionNumber) async {
    // 1. Fetch transaction details
    final txnResult =
        await _transactionManager.getTransaction(transactionNumber);

    if (txnResult['success'] != true || txnResult['transaction'] == null) {
      throw RefundException(
        'Transaction not found: $transactionNumber',
        errorCode: 'REFUND_NOT_FOUND',
      );
    }

    final transaction = txnResult['transaction'] as Map<String, dynamic>;

    // 2a. Must be status 3 (Success)
    final status = int.tryParse(transaction['status']?.toString() ?? '0') ?? 0;
    if (status != _statusSuccess) {
      throw const RefundException(
        'Transaction status is not eligible for refund.',
        errorCode: 'REFUND_INVALID_STATUS',
      );
    }

    // 2b. Must be within 3 months
    final txnDateRaw =
        transaction['txnDate'] ?? transaction['createdAt'];
    if (txnDateRaw != null) {
      DateTime? txnDate;
      if (txnDateRaw is int) {
        txnDate =
            DateTime.fromMillisecondsSinceEpoch(txnDateRaw * 1000);
      } else {
        txnDate = DateTime.tryParse(txnDateRaw.toString());
      }

      if (txnDate != null &&
          DateTime.now().difference(txnDate) > _maxRefundAge) {
        throw const RefundException(
          'Transaction is older than 3 months and cannot be refunded.',
          errorCode: 'REFUND_EXPIRED',
        );
      }
    }

    // 2c. Must not already be refunded
    final alreadyRefunded = transaction['isRefunded'] == true ||
        transaction['refunded'] == true ||
        transaction['isRefunded'] == 'true' ||
        transaction['refunded'] == 'true';

    if (alreadyRefunded) {
      throw const RefundException(
        'Transaction has already been refunded.',
        errorCode: 'REFUND_ALREADY_DONE',
      );
    }

    // 3. Post refund request
    try {
      final token = await _authenticator.getAccessToken();

      final response = await _httpClient.post(
        '${_config.getApiBaseUrl()}/transactions/refundTransaction',
        data: {'transactionnumber': transactionNumber},
        headers: {'Authorization': 'Bearer $token'},
      );

      return {
        'success': true,
        'refund_details': response,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
