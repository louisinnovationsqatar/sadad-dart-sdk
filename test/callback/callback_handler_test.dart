// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sadad_qatar/sadad_qatar.dart';
import 'package:test/test.dart';

void main() {
  group('CallbackHandler', () {
    const secretKey = 'callback-secret';
    const merchantId = '1234567';

    late SadadConfig config;
    late CallbackHandler handler;

    setUp(() {
      config = SadadConfig(
        merchantId: merchantId,
        secretKey: secretKey,
        website: 'www.example.com',
      );
      handler = CallbackHandler(config);
    });

    // ----------------------------------------------------------------
    // v1.1 callbacks
    // ----------------------------------------------------------------
    group('v1.1', () {
      Map<String, dynamic> buildV1Payload(Map<String, dynamic> base) {
        final hash = SignatureV1.generate(base, secretKey);
        return {...base, 'checksumhash': hash};
      }

      test('returns CallbackResult with isSuccess true for RESPCODE 1', () {
        final payload = buildV1Payload({
          'ORDERID': 'ORD-001',
          'transaction_number': 'TXN-001',
          'TXNAMOUNT': '150.00',
          'RESPCODE': '1',
          'RESPMSG': 'Transaction Successful',
          'STATUS': 'TXN_SUCCESS',
        });

        final result = handler.handle(payload, 'v1.1');

        expect(result.isSuccess, isTrue);
        expect(result.orderNumber, 'ORD-001');
        expect(result.transactionNumber, 'TXN-001');
        expect(result.amount, 150.00);
        expect(result.responseCode, '1');
        expect(result.responseMessage, 'Transaction Successful');
        expect(result.status, 'TXN_SUCCESS');
      });

      test('returns CallbackResult with isSuccess false for non-1 RESPCODE', () {
        final payload = buildV1Payload({
          'ORDERID': 'ORD-002',
          'transaction_number': 'TXN-002',
          'TXNAMOUNT': '75.00',
          'RESPCODE': '0',
          'RESPMSG': 'Transaction Failed',
          'STATUS': 'TXN_FAILURE',
        });

        final result = handler.handle(payload, 'v1.1');

        expect(result.isSuccess, isFalse);
      });

      test('throws SignatureException for invalid signature', () {
        final payload = {
          'ORDERID': 'ORD-003',
          'transaction_number': 'TXN-003',
          'TXNAMOUNT': '100.00',
          'RESPCODE': '1',
          'RESPMSG': 'OK',
          'STATUS': 'TXN_SUCCESS',
          'checksumhash': 'bad-hash',
        };

        expect(
          () => handler.handle(payload, 'v1.1'),
          throwsA(isA<SignatureException>()),
        );
      });
    });

    // ----------------------------------------------------------------
    // v2.1 callbacks
    // ----------------------------------------------------------------
    group('v2.1', () {
      Map<String, dynamic> buildV2Payload(Map<String, dynamic> base) {
        final encodedKey = Uri.encodeComponent(secretKey);
        final verificationData = {
          'postData': base,
          'secretKey': encodedKey,
        };

        const salt = 'X7mQ';
        final jsonString = jsonEncode(verificationData);
        final hash =
            sha256.convert(utf8.encode('$jsonString|$salt')).toString();
        final hashString = '$hash$salt';

        final encryptionKey = encodedKey + merchantId;
        final encrypted = AesEncryptor.encrypt(hashString, encryptionKey);

        return {...base, 'checksumhash': encrypted};
      }

      test('returns CallbackResult with isSuccess true for RESPCODE 1', () {
        final base = {
          'ORDERID': 'ORD-V2-001',
          'transaction_number': 'TXN-V2-001',
          'TXNAMOUNT': '200.00',
          'RESPCODE': '1',
          'RESPMSG': 'Success',
          'STATUS': 'TXN_SUCCESS',
        };

        final payload = buildV2Payload(base);
        final result = handler.handle(payload, 'v2.1');

        expect(result.isSuccess, isTrue);
        expect(result.orderNumber, 'ORD-V2-001');
        expect(result.amount, 200.00);
      });

      test('throws SignatureException for invalid v2 checksum', () {
        final payload = {
          'ORDERID': 'ORD-V2-BAD',
          'TXNAMOUNT': '100.00',
          'RESPCODE': '1',
          'checksumhash': 'invalid-checksum',
        };

        expect(
          () => handler.handle(payload, 'v2.1'),
          throwsA(isA<SignatureException>()),
        );
      });
    });

    // ----------------------------------------------------------------
    // v2.2 callbacks (same as v2.1)
    // ----------------------------------------------------------------
    group('v2.2', () {
      test('accepts v2.2 version and uses v2 verification', () {
        final encodedKey = Uri.encodeComponent(secretKey);
        final base = {
          'ORDERID': 'ORD-V22-001',
          'transaction_number': 'TXN-V22-001',
          'TXNAMOUNT': '99.00',
          'RESPCODE': '1',
          'RESPMSG': 'OK',
          'STATUS': 'TXN_SUCCESS',
        };

        final verificationData = {
          'postData': base,
          'secretKey': encodedKey,
        };

        const salt = 'P9kZ';
        final jsonString = jsonEncode(verificationData);
        final hash =
            sha256.convert(utf8.encode('$jsonString|$salt')).toString();
        final hashString = '$hash$salt';

        final encryptionKey = encodedKey + merchantId;
        final encrypted = AesEncryptor.encrypt(hashString, encryptionKey);

        final payload = {...base, 'checksumhash': encrypted};
        final result = handler.handle(payload, 'v2.2');

        expect(result.isSuccess, isTrue);
        expect(result.orderNumber, 'ORD-V22-001');
      });
    });

    // ----------------------------------------------------------------
    // Invalid version
    // ----------------------------------------------------------------
    test('throws ArgumentError for unsupported version', () {
      expect(
        () => handler.handle({'checksumhash': 'x'}, 'v3.0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('defaults to v1.1 when version not specified', () {
      final base = {
        'ORDERID': 'ORD-DEFAULT',
        'TXNAMOUNT': '10.00',
        'RESPCODE': '1',
        'RESPMSG': 'OK',
        'STATUS': 'TXN_SUCCESS',
      };
      final hash = SignatureV1.generate(base, secretKey);
      final payload = {...base, 'checksumhash': hash};

      final result = handler.handle(payload);
      expect(result.isSuccess, isTrue);
    });
  });
}
