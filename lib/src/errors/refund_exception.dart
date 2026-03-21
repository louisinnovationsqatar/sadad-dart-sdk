// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'sadad_exception.dart';

/// Thrown when a refund eligibility check fails.
///
/// Common error codes:
///   - `REFUND_NOT_FOUND`      — Transaction could not be found.
///   - `REFUND_INVALID_STATUS` — Transaction status is not eligible for refund.
///   - `REFUND_EXPIRED`        — Transaction is older than 3 months.
///   - `REFUND_ALREADY_DONE`   — Transaction has already been refunded.
class RefundException extends SadadException {
  const RefundException(
    super.message, {
    super.errorCode = 'REFUND_ERROR',
    super.cause,
  });

  @override
  String toString() => 'RefundException[$errorCode]: $message';
}
