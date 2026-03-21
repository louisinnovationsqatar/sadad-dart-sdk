// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'package:sadad_qatar/sadad_qatar.dart';
import 'package:test/test.dart';

void main() {
  group('SadadConfig', () {
    group('valid construction', () {
      test('creates with required parameters', () {
        final config = SadadConfig(
          merchantId: '1234567',
          secretKey: 'secret',
          website: 'www.example.com',
        );

        expect(config.merchantId, '1234567');
        expect(config.secretKey, 'secret');
        expect(config.website, 'www.example.com');
        expect(config.environment, 'test');
        expect(config.language, 'eng');
        expect(config.callbackUrl, isNull);
        expect(config.webhookUrl, isNull);
      });

      test('creates with all parameters', () {
        final config = SadadConfig(
          merchantId: '7654321',
          secretKey: 'my-secret',
          website: 'www.shop.qa',
          environment: 'live',
          language: 'arb',
          callbackUrl: 'https://shop.qa/callback',
          webhookUrl: 'https://shop.qa/webhook',
        );

        expect(config.environment, 'live');
        expect(config.language, 'arb');
        expect(config.callbackUrl, 'https://shop.qa/callback');
        expect(config.webhookUrl, 'https://shop.qa/webhook');
      });
    });

    group('merchantId validation', () {
      test('rejects fewer than 7 digits', () {
        expect(
          () => SadadConfig(
            merchantId: '123456',
            secretKey: 'secret',
            website: 'www.example.com',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('7 digits'),
          )),
        );
      });

      test('rejects more than 7 digits', () {
        expect(
          () => SadadConfig(
            merchantId: '12345678',
            secretKey: 'secret',
            website: 'www.example.com',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects non-numeric characters', () {
        expect(
          () => SadadConfig(
            merchantId: '123456a',
            secretKey: 'secret',
            website: 'www.example.com',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('accepts exactly 7 digits', () {
        expect(
          () => SadadConfig(
            merchantId: '0000000',
            secretKey: 'secret',
            website: 'www.example.com',
          ),
          returnsNormally,
        );
      });
    });

    group('secretKey validation', () {
      test('rejects empty secret key', () {
        expect(
          () => SadadConfig(
            merchantId: '1234567',
            secretKey: '',
            website: 'www.example.com',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('empty'),
          )),
        );
      });
    });

    group('environment validation', () {
      test('rejects invalid environment', () {
        expect(
          () => SadadConfig(
            merchantId: '1234567',
            secretKey: 'secret',
            website: 'www.example.com',
            environment: 'staging',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Environment'),
          )),
        );
      });

      test('accepts test environment', () {
        expect(
          () => SadadConfig(
            merchantId: '1234567',
            secretKey: 'secret',
            website: 'www.example.com',
            environment: 'test',
          ),
          returnsNormally,
        );
      });

      test('accepts live environment', () {
        expect(
          () => SadadConfig(
            merchantId: '1234567',
            secretKey: 'secret',
            website: 'www.example.com',
            environment: 'live',
          ),
          returnsNormally,
        );
      });
    });

    group('language validation', () {
      test('rejects invalid language', () {
        expect(
          () => SadadConfig(
            merchantId: '1234567',
            secretKey: 'secret',
            website: 'www.example.com',
            language: 'fr',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Language'),
          )),
        );
      });

      test('accepts eng language', () {
        expect(
          () => SadadConfig(
            merchantId: '1234567',
            secretKey: 'secret',
            website: 'www.example.com',
            language: 'eng',
          ),
          returnsNormally,
        );
      });

      test('accepts arb language', () {
        expect(
          () => SadadConfig(
            merchantId: '1234567',
            secretKey: 'secret',
            website: 'www.example.com',
            language: 'arb',
          ),
          returnsNormally,
        );
      });
    });

    group('getCheckoutUrl', () {
      late SadadConfig config;

      setUp(() {
        config = SadadConfig(
          merchantId: '1234567',
          secretKey: 'secret',
          website: 'www.example.com',
        );
      });

      test('returns v1.1 URL', () {
        expect(
          config.getCheckoutUrl('v1.1'),
          'https://sadadqa.com/webpurchase',
        );
      });

      test('returns v2.1 URL', () {
        expect(
          config.getCheckoutUrl('v2.1'),
          'https://sadadqa.com/webpurchase',
        );
      });

      test('returns v2.2 URL', () {
        expect(
          config.getCheckoutUrl('v2.2'),
          'https://secure.sadadqa.com/webpurchasepage',
        );
      });

      test('throws for unknown version', () {
        expect(
          () => config.getCheckoutUrl('v3.0'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    test('getApiBaseUrl returns correct URL', () {
      final config = SadadConfig(
        merchantId: '1234567',
        secretKey: 'secret',
        website: 'www.example.com',
      );
      expect(config.getApiBaseUrl(), 'https://api-s.sadad.qa/api');
    });
  });
}
