// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'sadad_exception.dart';

/// Thrown when SADAD API authentication fails or returns no access token.
class AuthenticationException extends SadadException {
  const AuthenticationException(
    super.message, {
    super.httpStatus,
    super.cause,
  }) : super(errorCode: 'AUTH_FAILED');

  @override
  String toString() => 'AuthenticationException[AUTH_FAILED]: $message';
}
