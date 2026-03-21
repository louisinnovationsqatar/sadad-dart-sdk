// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

/// AES-128-CBC encryptor using the SADAD fixed IV and key-truncation rules.
///
/// The encryption key is always truncated (or zero-padded) to 16 bytes.
/// The IV is fixed to `@@@@&&&&####$$$$` (16 bytes) as per the SADAD spec.
class AesEncryptor {
  static const String _iv = '@@@@&&&&####\$\$\$\$';

  AesEncryptor._();

  /// Encrypts [input] with [key] using AES-128-CBC and returns a base64 string.
  ///
  /// The [key] is truncated to 16 bytes, or padded with null bytes if shorter.
  /// Throws [StateError] if encryption fails.
  static String encrypt(String input, String key) {
    final keyBytes = _prepareKey(key);
    final ivBytes = IV.fromUtf8(_iv);
    final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(input, iv: ivBytes);
    return encrypted.base64;
  }

  /// Decrypts a base64-encoded [input] with [key] using AES-128-CBC.
  ///
  /// The [key] is truncated to 16 bytes, or padded with null bytes if shorter.
  /// Throws [StateError] if decryption fails.
  static String decrypt(String input, String key) {
    final keyBytes = _prepareKey(key);
    final ivBytes = IV.fromUtf8(_iv);
    final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));
    final encrypted = Encrypted.fromBase64(input);
    return encrypter.decrypt(encrypted, iv: ivBytes);
  }

  /// Prepares the AES key: truncate to 16 bytes or zero-pad if shorter.
  static Uint8List _prepareKey(String key) {
    final keyBytes = utf8.encode(key);
    final result = Uint8List(16);
    final len = keyBytes.length < 16 ? keyBytes.length : 16;
    for (var i = 0; i < len; i++) {
      result[i] = keyBytes[i];
    }
    return result;
  }
}
