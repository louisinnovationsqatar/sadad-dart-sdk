// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import '../sadad_config.dart';
import '../signature/signature_verifier.dart';
import 'webhook_result.dart';

/// Handles incoming SADAD webhook notifications.
class WebhookHandler {
  final SadadConfig _config;

  const WebhookHandler(this._config);

  /// Processes an incoming SADAD webhook [payload].
  ///
  /// 1. Verifies the SHA-256 `checksumhash` via [SignatureVerifier.verifyWebhook].
  /// 2. Parses the payload into a [WebhookResult] value object.
  /// 3. [WebhookResult.isSuccess] is `true` when `transactionStatus == 3`.
  ///
  /// Throws [SignatureException] if signature verification fails.
  WebhookResult handle(Map<String, dynamic> payload) {
    SignatureVerifier.verifyWebhook(payload, _config.secretKey);

    final transactionStatus =
        int.tryParse(payload['transactionStatus']?.toString() ?? '0') ?? 0;
    final isSuccess = transactionStatus == 3;

    return WebhookResult(
      isSuccess: isSuccess,
      message: payload['message']?.toString() ?? '',
      transactionNumber: payload['transaction_number']?.toString() ?? '',
      orderNumber: payload['ORDER_ID']?.toString() ?? '',
      amount: double.tryParse(payload['TXN_AMOUNT']?.toString() ?? '0') ?? 0.0,
      merchantId: payload['merchant_id']?.toString() ?? '',
      isTestMode: payload['isTestMode'] == true ||
          payload['isTestMode'] == 'true',
      invoiceNumber: payload['invoiceNumber']?.toString(),
    );
  }

  /// Returns the standard success acknowledgement map.
  ///
  /// SADAD expects the merchant webhook endpoint to respond with this JSON
  /// payload to confirm receipt.
  static Map<String, String> successResponse() => {'status': 'success'};
}
