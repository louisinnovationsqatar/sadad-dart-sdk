// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import '../sadad_config.dart';
import '../signature/signature_verifier.dart';
import 'callback_result.dart';

/// Handles SADAD payment callbacks (customer redirect back to merchant site).
class CallbackHandler {
  final SadadConfig _config;

  const CallbackHandler(this._config);

  /// Processes a SADAD payment callback [postData].
  ///
  /// Supported [version] values:
  ///   - `'v1.1'`  — SHA-256 signature via [SignatureVerifier.verifyV1Callback]
  ///   - `'v2.1'`  — AES-128-CBC checksum via [SignatureVerifier.verifyV2Callback]
  ///   - `'v2.2'`  — Same algorithm as v2.1
  ///
  /// Field mapping (SADAD POST fields → [CallbackResult] properties):
  ///   - `ORDERID`            → [CallbackResult.orderNumber]
  ///   - `transaction_number` → [CallbackResult.transactionNumber]
  ///   - `TXNAMOUNT`          → [CallbackResult.amount]
  ///   - `RESPCODE`           → [CallbackResult.responseCode]
  ///   - `RESPMSG`            → [CallbackResult.responseMessage]
  ///   - `STATUS`             → [CallbackResult.status]
  ///
  /// [CallbackResult.isSuccess] is `true` when `RESPCODE == '1'`.
  ///
  /// Throws [SignatureException] if signature verification fails.
  /// Throws [ArgumentError] if [version] is not supported.
  CallbackResult handle(
    Map<String, dynamic> postData, [
    String version = 'v1.1',
  ]) {
    switch (version) {
      case 'v1.1':
        SignatureVerifier.verifyV1Callback(postData, _config.secretKey);
      case 'v2.1':
      case 'v2.2':
        SignatureVerifier.verifyV2Callback(
          postData,
          _config.secretKey,
          _config.merchantId,
        );
      default:
        throw ArgumentError(
          'Unsupported callback version "$version". Supported: v1.1, v2.1, v2.2.',
        );
    }

    final respCode = postData['RESPCODE']?.toString() ?? '';
    final isSuccess = respCode == '1' || respCode == 1.toString();

    return CallbackResult(
      isSuccess: isSuccess,
      orderNumber: postData['ORDERID']?.toString() ?? '',
      transactionNumber: postData['transaction_number']?.toString() ?? '',
      amount: double.tryParse(postData['TXNAMOUNT']?.toString() ?? '0') ?? 0.0,
      responseCode: respCode,
      responseMessage: postData['RESPMSG']?.toString() ?? '',
      status: postData['STATUS']?.toString() ?? '',
    );
  }
}
