// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'sadad_exception.dart';

/// Thrown when webhook or callback signature verification fails.
class SignatureException extends SadadException {
  /// The expected (computed) hash.
  final String expectedHash;

  /// The received hash from the gateway payload.
  final String receivedHash;

  const SignatureException({
    required this.expectedHash,
    required this.receivedHash,
    String message = 'Signature verification failed',
  }) : super(message, errorCode: 'SIGNATURE_MISMATCH');

  @override
  String toString() => 'SignatureException[SIGNATURE_MISMATCH]: $message';
}
