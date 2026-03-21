// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../encryption/aes_encryptor.dart';
import '../encryption/salt_generator.dart';

/// Generates the AES-128-CBC encrypted checksum for SADAD v2 checkout.
class SignatureV2 {
  SignatureV2._();

  /// Generates an AES-128-CBC encrypted checksum for SADAD v2 checkout.
  ///
  /// Algorithm:
  ///   1. Build data object: `{'postData': postData, 'secretKey': secretKey}`
  ///   2. `jsonEncode(data)`
  ///   3. Generate 4-char salt via [SaltGenerator.generate]
  ///   4. Concatenate: `jsonString + '|' + salt`
  ///   5. `sha256(concatenated)` → 64-char hex string
  ///   6. Append salt: `hash + salt`  (68 chars total)
  ///   7. AES-128-CBC encrypt with key = `secretKey + merchantId` (truncated to 16 bytes)
  ///   8. Return base64-encoded encrypted string
  static String generate(
    Map<String, dynamic> postData,
    String secretKey,
    String merchantId,
  ) {
    final checksumData = {
      'postData': postData,
      'secretKey': secretKey,
    };

    final jsonString = jsonEncode(checksumData);
    final salt = SaltGenerator.generate(4);
    final finalString = '$jsonString|$salt';
    final hash = sha256.convert(utf8.encode(finalString)).toString();
    final hashString = '$hash$salt';

    final encryptionKey = secretKey + merchantId;
    return AesEncryptor.encrypt(hashString, encryptionKey);
  }
}
