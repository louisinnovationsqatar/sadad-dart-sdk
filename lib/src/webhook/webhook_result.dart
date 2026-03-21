// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

/// The parsed result of a SADAD webhook notification.
class WebhookResult {
  /// `true` when `transactionStatus == 3` (payment successful).
  final bool isSuccess;

  /// Response message from the gateway.
  final String message;

  /// Gateway-assigned transaction number.
  final String transactionNumber;

  /// Merchant order ID.
  final String orderNumber;

  /// Transaction amount.
  final double amount;

  /// Merchant ID echoed back by SADAD.
  final String merchantId;

  /// `true` when the transaction was processed in test mode.
  final bool isTestMode;

  /// Invoice number, if present in the payload.
  final String? invoiceNumber;

  const WebhookResult({
    required this.isSuccess,
    required this.message,
    required this.transactionNumber,
    required this.orderNumber,
    required this.amount,
    required this.merchantId,
    required this.isTestMode,
    this.invoiceNumber,
  });
}
