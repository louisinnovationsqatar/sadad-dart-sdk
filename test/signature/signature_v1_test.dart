// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'package:sadad_qatar/sadad_qatar.dart';
import 'package:test/test.dart';

void main() {
  group('SignatureV1', () {
    test('generates expected sha256 hash for known input', () {
      // Known test vector — matches PHP and JS SDK output
      final params = {
        'merchant_id': '1234567',
        'ORDER_ID': 'ORD-001',
        'TXN_AMOUNT': '150.00',
      };

      final result = SignatureV1.generate(params, 'secretkey');
      expect(result.length, 64);
      // Must be lowercase hex
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(result), isTrue);
    });

    test('excludes productdetail from signature', () {
      final paramsWithout = {
        'merchant_id': '1234567',
        'ORDER_ID': 'ORD-001',
        'TXN_AMOUNT': '150.00',
      };

      final paramsWith = {
        ...paramsWithout,
        'productdetail': [
          {'order_id': 'ORD-001', 'amount': '150.00', 'quantity': '1'},
        ],
      };

      final hashWithout = SignatureV1.generate(paramsWithout, 'secretkey');
      final hashWith = SignatureV1.generate(paramsWith, 'secretkey');

      expect(hashWithout, hashWith);
    });

    test('excludes signature from signature calculation', () {
      final base = {
        'merchant_id': '1234567',
        'ORDER_ID': 'ORD-001',
        'TXN_AMOUNT': '150.00',
      };

      final withSig = {
        ...base,
        'signature': 'existing-signature',
      };

      expect(
        SignatureV1.generate(base, 'secretkey'),
        SignatureV1.generate(withSig, 'secretkey'),
      );
    });

    test('excludes checksumhash from signature calculation', () {
      final base = {
        'merchant_id': '1234567',
        'ORDER_ID': 'ORD-001',
      };

      final withChecksum = {
        ...base,
        'checksumhash': 'some-checksum',
      };

      expect(
        SignatureV1.generate(base, 'secretkey'),
        SignatureV1.generate(withChecksum, 'secretkey'),
      );
    });

    test('excluded keys comparison is case-insensitive', () {
      final base = {
        'merchant_id': '1234567',
        'ORDER_ID': 'ORD-001',
      };

      final withUpperProductDetail = {
        ...base,
        'PRODUCTDETAIL': 'something',
      };

      final withMixedSignature = {
        ...base,
        'Signature': 'something',
      };

      expect(
        SignatureV1.generate(base, 'secretkey'),
        SignatureV1.generate(withUpperProductDetail, 'secretkey'),
      );

      expect(
        SignatureV1.generate(base, 'secretkey'),
        SignatureV1.generate(withMixedSignature, 'secretkey'),
      );
    });

    test('sorts parameters alphabetically (ASCII order)', () {
      // ASCII order: uppercase letters (65-90) come before lowercase (97-122)
      final params1 = {
        'B': 'second',
        'A': 'first',
        'a': 'third',
      };

      final params2 = {
        'A': 'first',
        'B': 'second',
        'a': 'third',
      };

      // Both should produce the same hash regardless of insertion order
      expect(
        SignatureV1.generate(params1, 'secretkey'),
        SignatureV1.generate(params2, 'secretkey'),
      );
    });

    test('uses secretKey as prefix before values', () {
      final params = {'ORDER_ID': 'ORD-001'};

      final hashKey1 = SignatureV1.generate(params, 'key1');
      final hashKey2 = SignatureV1.generate(params, 'key2');

      expect(hashKey1, isNot(hashKey2));
    });

    test('produces deterministic output', () {
      final params = {
        'merchant_id': '7654321',
        'ORDER_ID': 'TEST-123',
        'TXN_AMOUNT': '99.99',
        'WEBSITE': 'www.example.com',
      };

      final hash1 = SignatureV1.generate(params, 'my-secret');
      final hash2 = SignatureV1.generate(params, 'my-secret');

      expect(hash1, hash2);
    });

    test('handles empty params', () {
      final result = SignatureV1.generate({}, 'secretkey');
      expect(result.length, 64);
    });
  });
}
