// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../encryption/aes_encryptor.dart';
import '../errors/signature_exception.dart';
import 'signature_v1.dart';

/// Verifies SADAD payment signatures for callbacks and webhooks.
class SignatureVerifier {
  SignatureVerifier._();

  /// Verifies a SADAD v1 callback by comparing the received [checksumhash]
  /// against a freshly-computed hash from the remaining parameters.
  ///
  /// Throws [SignatureException] when the signature does not match.
  /// Returns `true` on success.
  static bool verifyV1Callback(
    Map<String, dynamic> params,
    String secretKey,
  ) {
    final mutableParams = Map<String, dynamic>.from(params);
    final received = mutableParams.remove('checksumhash')?.toString() ?? '';

    final expected = SignatureV1.generate(mutableParams, secretKey);

    if (!_secureCompare(expected, received)) {
      throw SignatureException(
        expectedHash: expected,
        receivedHash: received,
      );
    }

    return true;
  }

  /// Verifies a SADAD webhook payload using the v1 signature algorithm.
  ///
  /// Functionally identical to [verifyV1Callback] — provided as a named alias
  /// for webhook use-cases for clarity.
  ///
  /// Throws [SignatureException] when the signature does not match.
  /// Returns `true` on success.
  static bool verifyWebhook(
    Map<String, dynamic> payload,
    String secretKey,
  ) {
    final mutablePayload = Map<String, dynamic>.from(payload);
    final received = mutablePayload.remove('checksumhash')?.toString() ?? '';

    final expected = SignatureV1.generate(mutablePayload, secretKey);

    if (!_secureCompare(expected, received)) {
      throw SignatureException(
        expectedHash: expected,
        receivedHash: received,
      );
    }

    return true;
  }

  /// Verifies a SADAD v2 callback checksum.
  ///
  /// SADAD v2 verification protocol uses [Uri.encodeComponent] of the
  /// [secretKey] in both the JSON data object and the AES decryption key.
  /// This differs from generation (which uses the raw key) and is per the
  /// SADAD spec.
  ///
  /// Algorithm:
  ///   1. Extract and remove `checksumhash` from params.
  ///   2. Build verification data: `{'postData': params, 'secretKey': Uri.encodeComponent(secretKey)}`
  ///   3. Decrypt `checksumhash` using key: `Uri.encodeComponent(secretKey) + merchantId`
  ///   4. Extract salt (last 4 chars) and hash (first 64 chars) from decrypted string.
  ///   5. Re-derive: `sha256(jsonEncode(verificationData) + '|' + salt)`
  ///   6. Compare. Throw [SignatureException] on mismatch.
  ///
  /// Throws [SignatureException] when the checksum does not match or decryption fails.
  /// Returns `true` on success.
  static bool verifyV2Callback(
    Map<String, dynamic> params,
    String secretKey,
    String merchantId,
  ) {
    final mutableParams = Map<String, dynamic>.from(params);
    final receivedChecksum =
        mutableParams.remove('checksumhash')?.toString() ?? '';

    final encodedKey = Uri.encodeComponent(secretKey);

    final verificationData = {
      'postData': mutableParams,
      'secretKey': encodedKey,
    };

    final decryptionKey = encodedKey + merchantId;

    String decrypted;
    try {
      decrypted = AesEncryptor.decrypt(receivedChecksum, decryptionKey);
    } catch (e) {
      throw SignatureException(
        expectedHash: '',
        receivedHash: receivedChecksum,
        message: 'Checksum decryption failed: $e',
      );
    }

    if (decrypted.length < 68) {
      throw SignatureException(
        expectedHash: '',
        receivedHash: receivedChecksum,
        message: 'Decrypted checksum is too short.',
      );
    }

    final hash = decrypted.substring(0, 64);
    final salt = decrypted.substring(64, 68);

    final jsonString = jsonEncode(verificationData);
    final expectedHash =
        sha256.convert(utf8.encode('$jsonString|$salt')).toString();

    if (!_secureCompare(expectedHash, hash)) {
      throw SignatureException(
        expectedHash: expectedHash,
        receivedHash: hash,
      );
    }

    return true;
  }

  /// Constant-time string comparison to prevent timing attacks.
  static bool _secureCompare(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
