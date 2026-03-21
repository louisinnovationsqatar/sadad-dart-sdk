// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Generates the SHA-256 signature for SADAD v1.1 web checkout.
class SignatureV1 {
  /// Keys excluded from the signature calculation (compared case-insensitively).
  static const List<String> _excludedKeys = [
    'productdetail',
    'signature',
    'checksumhash',
  ];

  SignatureV1._();

  /// Generates a SHA-256 signature for the given [params].
  ///
  /// Algorithm (SADAD v1.1 spec):
  ///   1. Remove `productdetail`, `signature`, and `checksumhash` (case-insensitive).
  ///   2. Sort the remaining parameters by key name using case-sensitive
  ///      alphabetical ordering (ASCII order — uppercase before lowercase).
  ///   3. Construct the string: secretKey + value1 + value2 + ...
  ///      (values only, in sorted-key order, no separators).
  ///   4. Return sha256(string) as a lowercase hex string.
  ///
  /// Returns a 64-character lowercase hex SHA-256 hash.
  static String generate(Map<String, dynamic> params, String secretKey) {
    // Step 1: Remove excluded keys (case-insensitive)
    final filtered = <String, dynamic>{};
    for (final entry in params.entries) {
      if (!_excludedKeys.contains(entry.key.toLowerCase())) {
        filtered[entry.key] = entry.value;
      }
    }

    // Step 2: Case-sensitive alphabetical sort (ASCII order)
    final sortedKeys = filtered.keys.toList()..sort();

    // Step 3: Build the string to hash
    final buffer = StringBuffer(secretKey);
    for (final key in sortedKeys) {
      buffer.write(filtered[key].toString());
    }

    // Step 4: SHA-256
    final bytes = utf8.encode(buffer.toString());
    return sha256.convert(bytes).toString();
  }
}
