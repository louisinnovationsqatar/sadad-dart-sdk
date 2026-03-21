// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'dart:math';

/// Generates cryptographically-secure random salts from the SADAD charset.
class SaltGenerator {
  static const String _charset =
      'AbcDE123IJKLMN67QRSTUVWXYZaBCdefghijklmn123opq45rs67tuv89wxyz0FGH45OP89';

  SaltGenerator._();

  /// Generates a [length]-character random salt from the SADAD charset.
  ///
  /// Uses [Random.secure()] for cryptographic randomness.
  /// Defaults to 4 characters as required by the v2 checksum algorithm.
  static String generate([int length = 4]) {
    final random = Random.secure();
    const charsetLength = _charset.length;
    final buffer = StringBuffer();

    for (var i = 0; i < length; i++) {
      buffer.write(_charset[random.nextInt(charsetLength)]);
    }

    return buffer.toString();
  }
}
