// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'package:sadad_qatar/sadad_qatar.dart';
import 'package:test/test.dart';

import '../helpers/mock_http_client.dart';

void main() {
  group('RefundManager eligibility validation', () {
    late SadadConfig config;
    late MockHttpClient httpClient;

    setUp(() {
      config = SadadConfig(
        merchantId: '1234567',
        secretKey: 'secret',
        website: 'www.example.com',
      );
      httpClient = MockHttpClient();
    });

    RefundManager buildManager() {
      final authenticator = Authenticator(config, httpClient);
      final transactionManager =
          TransactionManager(config, httpClient, authenticator);
      return RefundManager(
        config,
        httpClient,
        authenticator,
        transactionManager,
      );
    }

    test('throws REFUND_NOT_FOUND when transaction HTTP call throws', () async {
      httpClient.onPost = (url, data, headers) async {
        if (url.contains('login')) {
          return {'accessToken': 'test-token'};
        }
        return {};
      };

      // Throw from getTransaction so its result has success: false
      httpClient.onGet = (url, params, headers) {
        throw const SadadException('Not found', errorCode: 'NOT_FOUND');
      };

      final manager = buildManager();

      await expectLater(
        manager.refund('TXN-MISSING'),
        throwsA(
          isA<RefundException>().having(
            (e) => e.errorCode,
            'errorCode',
            'REFUND_NOT_FOUND',
          ),
        ),
      );
    });

    test('throws REFUND_INVALID_STATUS when status is not 3', () async {
      httpClient.onPost = (url, data, headers) async {
        if (url.contains('login')) {
          return {'accessToken': 'test-token'};
        }
        return {};
      };

      httpClient.onGet = (url, params, headers) async => {
            'status': '2', // Not success status
            'txnDate': DateTime.now().toIso8601String(),
            'isRefunded': false,
          };

      final manager = buildManager();

      await expectLater(
        manager.refund('TXN-WRONG-STATUS'),
        throwsA(
          isA<RefundException>().having(
            (e) => e.errorCode,
            'errorCode',
            'REFUND_INVALID_STATUS',
          ),
        ),
      );
    });

    test('throws REFUND_EXPIRED when transaction is older than 90 days',
        () async {
      httpClient.onPost = (url, data, headers) async {
        if (url.contains('login')) {
          return {'accessToken': 'test-token'};
        }
        return {};
      };

      final oldDate = DateTime.now().subtract(const Duration(days: 91));

      httpClient.onGet = (url, params, headers) async => {
            'status': '3',
            'txnDate': oldDate.toIso8601String(),
            'isRefunded': false,
          };

      final manager = buildManager();

      await expectLater(
        manager.refund('TXN-EXPIRED'),
        throwsA(
          isA<RefundException>().having(
            (e) => e.errorCode,
            'errorCode',
            'REFUND_EXPIRED',
          ),
        ),
      );
    });

    test('throws REFUND_ALREADY_DONE when isRefunded is true', () async {
      httpClient.onPost = (url, data, headers) async {
        if (url.contains('login')) {
          return {'accessToken': 'test-token'};
        }
        return {};
      };

      httpClient.onGet = (url, params, headers) async => {
            'status': '3',
            'txnDate': DateTime.now().toIso8601String(),
            'isRefunded': true,
          };

      final manager = buildManager();

      await expectLater(
        manager.refund('TXN-ALREADY-REFUNDED'),
        throwsA(
          isA<RefundException>().having(
            (e) => e.errorCode,
            'errorCode',
            'REFUND_ALREADY_DONE',
          ),
        ),
      );
    });

    test('succeeds for eligible transaction within 90 days', () async {
      httpClient.onPost = (url, data, headers) async {
        if (url.contains('login')) {
          return {'accessToken': 'test-token'};
        }
        if (url.contains('refundTransaction')) {
          return {'refundStatus': 'success', 'refundId': 'REF-001'};
        }
        return {};
      };

      final recentDate = DateTime.now().subtract(const Duration(days: 30));

      httpClient.onGet = (url, params, headers) async => {
            'status': '3',
            'txnDate': recentDate.toIso8601String(),
            'isRefunded': false,
          };

      final manager = buildManager();
      final result = await manager.refund('TXN-VALID');

      expect(result['success'], isTrue);
      expect(result['refund_details'], isNotNull);
    });

    test('RefundException errorCode is preserved', () {
      const exception = RefundException(
        'Test error',
        errorCode: 'REFUND_TEST',
      );

      expect(exception.errorCode, 'REFUND_TEST');
      expect(exception.message, 'Test error');
    });
  });
}
