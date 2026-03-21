// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'package:sadad_qatar/sadad_qatar.dart';
import 'package:test/test.dart';

void main() {
  group('WebhookHandler', () {
    const secretKey = 'webhook-secret';

    late SadadConfig config;
    late WebhookHandler handler;

    setUp(() {
      config = SadadConfig(
        merchantId: '1234567',
        secretKey: secretKey,
        website: 'www.example.com',
      );
      handler = WebhookHandler(config);
    });

    Map<String, dynamic> buildPayload(Map<String, dynamic> base) {
      final hash = SignatureV1.generate(base, secretKey);
      return {...base, 'checksumhash': hash};
    }

    test('returns WebhookResult with isSuccess true when transactionStatus is 3', () {
      final payload = buildPayload({
        'transaction_number': 'TXN-99999',
        'ORDER_ID': 'ORD-100',
        'TXN_AMOUNT': '250.00',
        'merchant_id': '1234567',
        'message': 'Payment successful',
        'transactionStatus': '3',
        'isTestMode': false,
      });

      final result = handler.handle(payload);

      expect(result.isSuccess, isTrue);
      expect(result.transactionNumber, 'TXN-99999');
      expect(result.orderNumber, 'ORD-100');
      expect(result.amount, 250.00);
      expect(result.merchantId, '1234567');
      expect(result.message, 'Payment successful');
      expect(result.isTestMode, isFalse);
      expect(result.invoiceNumber, isNull);
    });

    test('returns WebhookResult with isSuccess false when transactionStatus is not 3', () {
      final payload = buildPayload({
        'transaction_number': 'TXN-12345',
        'ORDER_ID': 'ORD-200',
        'TXN_AMOUNT': '100.00',
        'merchant_id': '1234567',
        'message': 'Payment failed',
        'transactionStatus': '2',
        'isTestMode': false,
      });

      final result = handler.handle(payload);

      expect(result.isSuccess, isFalse);
    });

    test('includes invoiceNumber when present in payload', () {
      final payload = buildPayload({
        'transaction_number': 'TXN-111',
        'ORDER_ID': 'ORD-111',
        'TXN_AMOUNT': '75.00',
        'merchant_id': '1234567',
        'transactionStatus': '3',
        'invoiceNumber': 'INV-2025-001',
      });

      final result = handler.handle(payload);

      expect(result.invoiceNumber, 'INV-2025-001');
    });

    test('isTestMode is true when payload contains isTestMode: true', () {
      final payload = buildPayload({
        'transaction_number': 'TXN-222',
        'ORDER_ID': 'ORD-222',
        'TXN_AMOUNT': '50.00',
        'merchant_id': '1234567',
        'transactionStatus': '3',
        'isTestMode': true,
      });

      final result = handler.handle(payload);

      expect(result.isTestMode, isTrue);
    });

    test('throws SignatureException for invalid signature', () {
      final payload = {
        'transaction_number': 'TXN-BAD',
        'ORDER_ID': 'ORD-BAD',
        'TXN_AMOUNT': '100.00',
        'merchant_id': '1234567',
        'transactionStatus': '3',
        'checksumhash': 'invalid-hash',
      };

      expect(
        () => handler.handle(payload),
        throwsA(isA<SignatureException>()),
      );
    });

    test('successResponse returns expected map', () {
      expect(WebhookHandler.successResponse(), {'status': 'success'});
    });
  });
}
