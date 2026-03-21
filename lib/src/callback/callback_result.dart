// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

/// The parsed result of a SADAD payment callback.
class CallbackResult {
  /// `true` when `RESPCODE == '1'`.
  final bool isSuccess;

  /// Merchant order ID (from `ORDERID` field).
  final String orderNumber;

  /// Gateway transaction number.
  final String transactionNumber;

  /// Transaction amount (from `TXNAMOUNT` field).
  final double amount;

  /// SADAD response code (from `RESPCODE` field).
  final String responseCode;

  /// Human-readable response message (from `RESPMSG` field).
  final String responseMessage;

  /// Raw transaction status string (from `STATUS` field).
  final String status;

  const CallbackResult({
    required this.isSuccess,
    required this.orderNumber,
    required this.transactionNumber,
    required this.amount,
    required this.responseCode,
    required this.responseMessage,
    required this.status,
  });
}
