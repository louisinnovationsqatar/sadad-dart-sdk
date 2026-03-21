// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'package:sadad_qatar/sadad_qatar.dart';
import 'package:test/test.dart';

void main() {
  group('AesEncryptor', () {
    test('encrypts and decrypts round-trip', () {
      const key = 'my-secret-key-16';
      const plaintext = 'hello world';

      final encrypted = AesEncryptor.encrypt(plaintext, key);
      final decrypted = AesEncryptor.decrypt(encrypted, key);

      expect(decrypted, plaintext);
    });

    test('encrypt returns base64 string', () {
      const key = 'test-key-1234567';
      const plaintext = 'test data';

      final encrypted = AesEncryptor.encrypt(plaintext, key);

      // Base64 characters only
      expect(RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(encrypted), isTrue);
    });

    test('truncates key to 16 bytes', () {
      const key = 'this-is-a-very-long-secret-key-that-exceeds-16-bytes';
      const plaintext = 'test data';

      // Should not throw
      final encrypted = AesEncryptor.encrypt(plaintext, key);
      final decrypted = AesEncryptor.decrypt(encrypted, key);

      expect(decrypted, plaintext);
    });

    test('pads short key with null bytes', () {
      const key = 'short';
      const plaintext = 'test data';

      final encrypted = AesEncryptor.encrypt(plaintext, key);
      final decrypted = AesEncryptor.decrypt(encrypted, key);

      expect(decrypted, plaintext);
    });

    test('produces deterministic output for same input', () {
      const key = 'deterministic-key';
      const plaintext = 'same input same output';

      final enc1 = AesEncryptor.encrypt(plaintext, key);
      final enc2 = AesEncryptor.encrypt(plaintext, key);

      // AES-CBC with fixed IV is deterministic
      expect(enc1, enc2);
    });

    test('produces different ciphertext for different inputs', () {
      const key = 'test-key-16bytes';

      final enc1 = AesEncryptor.encrypt('input one', key);
      final enc2 = AesEncryptor.encrypt('input two', key);

      expect(enc1, isNot(enc2));
    });

    test('produces different ciphertext for different keys', () {
      const plaintext = 'same plaintext';

      final enc1 = AesEncryptor.encrypt(plaintext, 'key-number-one-1');
      final enc2 = AesEncryptor.encrypt(plaintext, 'key-number-two-2');

      expect(enc1, isNot(enc2));
    });

    test('encrypts unicode and special characters', () {
      const key = 'test-key-16bytes';
      const plaintext = 'amount=150.00&currency=QAR';

      final encrypted = AesEncryptor.encrypt(plaintext, key);
      final decrypted = AesEncryptor.decrypt(encrypted, key);

      expect(decrypted, plaintext);
    });

    test('encrypts long hash+salt string like signature v2 uses', () {
      const key = 'secretkey1234567';
      // 68 chars: 64-char sha256 hex + 4-char salt
      final plaintext =
          'a' * 64 + 'Ab1X';

      final encrypted = AesEncryptor.encrypt(plaintext, key);
      final decrypted = AesEncryptor.decrypt(encrypted, key);

      expect(decrypted, plaintext);
    });
  });
}
