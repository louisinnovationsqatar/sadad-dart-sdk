// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sadad_qatar/sadad_qatar.dart';
import 'package:test/test.dart';

void main() {
  group('SignatureVerifier', () {
    const secretKey = 'my-secret-key';
    const merchantId = '1234567';

    // ----------------------------------------------------------------
    // verifyV1Callback
    // ----------------------------------------------------------------
    group('verifyV1Callback', () {
      test('returns true for valid signature', () {
        final params = {
          'merchant_id': merchantId,
          'ORDER_ID': 'ORD-001',
          'TXN_AMOUNT': '150.00',
        };

        // Generate expected hash
        final expected = SignatureV1.generate(params, secretKey);
        final callbackParams = {...params, 'checksumhash': expected};

        expect(
          SignatureVerifier.verifyV1Callback(callbackParams, secretKey),
          isTrue,
        );
      });

      test('throws SignatureException for wrong checksumhash', () {
        final params = {
          'merchant_id': merchantId,
          'ORDER_ID': 'ORD-001',
          'checksumhash': 'wrong-hash',
        };

        expect(
          () => SignatureVerifier.verifyV1Callback(params, secretKey),
          throwsA(isA<SignatureException>()),
        );
      });

      test('throws SignatureException for tampered payload', () {
        final params = {
          'merchant_id': merchantId,
          'ORDER_ID': 'ORD-001',
          'TXN_AMOUNT': '150.00',
        };

        final hash = SignatureV1.generate(params, secretKey);

        // Tamper the amount
        final tampered = {
          'merchant_id': merchantId,
          'ORDER_ID': 'ORD-001',
          'TXN_AMOUNT': '999.00', // tampered
          'checksumhash': hash,
        };

        expect(
          () => SignatureVerifier.verifyV1Callback(tampered, secretKey),
          throwsA(isA<SignatureException>()),
        );
      });

      test('throws SignatureException for wrong secret key', () {
        final params = {
          'merchant_id': merchantId,
          'ORDER_ID': 'ORD-001',
        };

        final hash = SignatureV1.generate(params, secretKey);
        final callbackParams = {...params, 'checksumhash': hash};

        expect(
          () => SignatureVerifier.verifyV1Callback(
            callbackParams,
            'wrong-key',
          ),
          throwsA(isA<SignatureException>()),
        );
      });

      test('SignatureException contains expected and received hashes', () {
        final params = {
          'ORDER_ID': 'ORD-001',
          'checksumhash': 'bad-hash',
        };

        try {
          SignatureVerifier.verifyV1Callback(params, secretKey);
          fail('Should have thrown');
        } on SignatureException catch (e) {
          expect(e.receivedHash, 'bad-hash');
          expect(e.expectedHash, isNotEmpty);
          expect(e.errorCode, 'SIGNATURE_MISMATCH');
        }
      });
    });

    // ----------------------------------------------------------------
    // verifyWebhook
    // ----------------------------------------------------------------
    group('verifyWebhook', () {
      test('returns true for valid webhook payload', () {
        final payload = {
          'transaction_number': 'TXN-123',
          'ORDER_ID': 'ORD-001',
          'TXN_AMOUNT': '150.00',
          'transactionStatus': '3',
        };

        final hash = SignatureV1.generate(payload, secretKey);
        final fullPayload = {...payload, 'checksumhash': hash};

        expect(
          SignatureVerifier.verifyWebhook(fullPayload, secretKey),
          isTrue,
        );
      });

      test('throws SignatureException for invalid webhook signature', () {
        final payload = {
          'ORDER_ID': 'ORD-001',
          'checksumhash': 'invalid',
        };

        expect(
          () => SignatureVerifier.verifyWebhook(payload, secretKey),
          throwsA(isA<SignatureException>()),
        );
      });
    });

    // ----------------------------------------------------------------
    // verifyV2Callback
    // ----------------------------------------------------------------
    group('verifyV2Callback', () {
      // Build a valid v2 checksum using the verification protocol:
      // verification uses Uri.encodeComponent(secretKey) in both
      // the JSON and the AES key.
      Map<String, dynamic> buildValidV2Payload(
        Map<String, dynamic> params,
        String secret,
        String merchant,
      ) {
        final encodedKey = Uri.encodeComponent(secret);
        final verificationData = {
          'postData': params,
          'secretKey': encodedKey,
        };

        const salt = 'Ab1X'; // deterministic for testing
        final jsonString = jsonEncode(verificationData);
        final hash =
            sha256.convert(utf8.encode('$jsonString|$salt')).toString();
        final hashString = '$hash$salt';

        final encryptionKey = encodedKey + merchant;
        final encrypted = AesEncryptor.encrypt(hashString, encryptionKey);

        return {...params, 'checksumhash': encrypted};
      }

      test('returns true for valid v2 checksum', () {
        final params = {
          'merchant_id': merchantId,
          'ORDER_ID': 'ORD-001',
          'TXN_AMOUNT': '150.00',
        };

        final payload = buildValidV2Payload(params, secretKey, merchantId);

        expect(
          SignatureVerifier.verifyV2Callback(payload, secretKey, merchantId),
          isTrue,
        );
      });

      test('throws SignatureException for wrong secret key', () {
        final params = {
          'merchant_id': merchantId,
          'ORDER_ID': 'ORD-001',
          'TXN_AMOUNT': '150.00',
        };

        final payload = buildValidV2Payload(params, secretKey, merchantId);

        expect(
          () => SignatureVerifier.verifyV2Callback(
            payload,
            'wrong-key',
            merchantId,
          ),
          throwsA(isA<SignatureException>()),
        );
      });

      test('throws SignatureException for tampered payload', () {
        final params = {
          'merchant_id': merchantId,
          'ORDER_ID': 'ORD-001',
          'TXN_AMOUNT': '150.00',
        };

        final payload = buildValidV2Payload(params, secretKey, merchantId);

        // Tamper after checksum generation
        final tampered = Map<String, dynamic>.from(payload);
        tampered['TXN_AMOUNT'] = '999.99';

        expect(
          () => SignatureVerifier.verifyV2Callback(
            tampered,
            secretKey,
            merchantId,
          ),
          throwsA(isA<SignatureException>()),
        );
      });

      test('throws SignatureException for invalid base64 checksum', () {
        final params = {
          'merchant_id': merchantId,
          'ORDER_ID': 'ORD-001',
          'checksumhash': 'not-valid-base64!!!',
        };

        expect(
          () => SignatureVerifier.verifyV2Callback(
            params,
            secretKey,
            merchantId,
          ),
          throwsA(isA<SignatureException>()),
        );
      });
    });
  });
}
