// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

/// Base exception for all SADAD SDK errors.
class SadadException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Machine-readable error code (e.g. `'SADAD_ERROR'`).
  final String errorCode;

  /// HTTP status code from the gateway response, if applicable.
  final int? httpStatus;

  /// The original exception that caused this error, if any.
  final Object? cause;

  const SadadException(
    this.message, {
    this.errorCode = 'SADAD_ERROR',
    this.httpStatus,
    this.cause,
  });

  @override
  String toString() => 'SadadException[$errorCode]: $message';
}
