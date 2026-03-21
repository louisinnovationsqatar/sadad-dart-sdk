# SADAD Payment Gateway SDK for Dart

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Dart: 3.0+](https://img.shields.io/badge/Dart-3.0%2B-blue.svg)](https://dart.dev/)
[![pub.dev](https://img.shields.io/pub/v/sadad_qatar.svg)](https://pub.dev/packages/sadad_qatar)

Official Dart SDK for the [SADAD Payment Gateway](https://www.sadad.qa/) — Qatar's leading payment platform.

## Features

- [x] Three checkout modes: Web Redirect (v1.1), Enhanced Redirect (v2.1), Embedded/iFrame (v2.2)
- [x] Invoice management: create, share via SMS or email, list
- [x] Full refunds with eligibility validation
- [x] Webhook handling with signature verification
- [x] Payment callback handling (v1.1, v2.1, v2.2)
- [x] SHA-256 and AES-128-CBC signature generation and verification
- [x] Transaction lookup
- [x] Dart 3.0+ with null safety

## Requirements

- Dart SDK `^3.0.0`
- Dependencies: `crypto`, `encrypt`, `http`

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  sadad_qatar: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:sadad_qatar/sadad_qatar.dart';

final config = SadadConfig(
  merchantId:  '1234567',           // 7-digit SADAD merchant ID
  secretKey:   'your-secret-key',
  website:     'www.your-domain.com',
  environment: 'test',              // 'test' or 'live'
  language:    'eng',               // 'eng' or 'arb'
  callbackUrl: 'https://www.your-domain.com/payment/callback',
  webhookUrl:  'https://www.your-domain.com/payment/webhook',
);

final client = SadadClient(config);

// Create a v1.1 checkout
final result = client.checkout({
  'order_id': 'ORD-001',
  'amount':   150.00,
  'mobile':   '97412345678',
  'email':    'customer@example.com',
  'items': [
    {'order_id': 'ORD-001', 'amount': 150.00, 'quantity': 1},
  ],
});

// Generate a self-submitting HTML form
print(result.toHtmlForm());
```

## Configuration

All configuration is passed to `SadadConfig`. Only the last four parameters are optional.

| Parameter      | Type      | Required | Description                                              |
|----------------|-----------|----------|----------------------------------------------------------|
| `merchantId`   | `String`  | Yes      | Your 7-digit SADAD merchant ID                           |
| `secretKey`    | `String`  | Yes      | Your SADAD secret key                                    |
| `website`      | `String`  | Yes      | Your website domain (e.g. `www.your-domain.com`)         |
| `environment`  | `String`  | No       | `'test'` (default) or `'live'`                           |
| `language`     | `String`  | No       | `'eng'` (default) or `'arb'`                             |
| `callbackUrl`  | `String?` | No       | URL SADAD redirects the customer to after payment        |
| `webhookUrl`   | `String?` | No       | URL SADAD posts payment notifications to                 |

## Checkout Modes

### v1.1 — Standard Web Redirect

The customer is redirected to the SADAD payment page. A SHA-256 signature is generated from the order parameters.

```dart
final result = client.checkout(orderData, 'v1.1');
// result.url + result.params — redirect the customer
print(result.toHtmlForm());
```

### v2.1 — Enhanced Web Redirect

Same redirect flow as v1.1 but uses an AES-128-CBC encrypted checksum for improved security.

```dart
final result = client.checkout(orderData, 'v2.1');
print(result.toHtmlForm()); // Auto-submitting HTML form
```

### v2.2 — Embedded / iFrame Checkout

Renders an embedded payment widget on your page.

```dart
final result = client.checkout(orderData, 'v2.2');
print(result.toHtmlForm(formId: 'sadad-frame', autoSubmit: false));
```

### Order data structure

```dart
final orderData = {
  'order_id':     'ORD-001',              // Your unique order identifier
  'amount':       150.00,                 // Total amount in QAR
  'mobile':       '97412345678',          // Customer mobile (digits only)
  'email':        'customer@example.com',
  'callback_url': 'https://...',          // Optional: overrides config callbackUrl
  'items': [
    {
      'order_id': 'ORD-001',
      'amount':   150.00,
      'quantity': 1,
    },
  ],
};
```

## Webhook Setup

1. Log in to [panel.sadad.qa](https://panel.sadad.qa) and register your webhook URL.
2. In your webhook endpoint, pass the raw POST data to the handler:

```dart
final payload = jsonDecode(requestBody) as Map<String, dynamic>;

try {
  final result = client.handleWebhook(payload);

  if (result.isSuccess) {
    // Payment confirmed — fulfil the order
    print('Transaction: ${result.transactionNumber}');
    print('Order:       ${result.orderNumber}');
    print('Amount:      QAR ${result.amount}');
  }

  // Respond to SADAD
  return jsonEncode(SadadClient.webhookSuccessResponse());

} on SignatureException catch (e) {
  // Signature invalid — reject the request (return 400)
  return Response(statusCode: 400);
}
```

`WebhookResult` properties:

| Property            | Type      | Description                                        |
|---------------------|-----------|----------------------------------------------------|
| `isSuccess`         | `bool`    | `true` when `transactionStatus == 3`               |
| `transactionNumber` | `String`  | SADAD transaction reference                        |
| `orderNumber`       | `String`  | Your original order ID                             |
| `amount`            | `double`  | Transaction amount                                 |
| `merchantId`        | `String`  | Merchant ID echoed back by SADAD                   |
| `message`           | `String`  | Human-readable status message                      |
| `isTestMode`        | `bool`    | Whether the transaction was in test mode           |
| `invoiceNumber`     | `String?` | Invoice number if applicable                       |

## Payment Callback

Handle the customer redirect back to your site after payment:

```dart
// v1.1 callback
final result = client.handleCallback(postData, 'v1.1');

// v2.1 or v2.2 callback
final result = client.handleCallback(postData, 'v2.1');

if (result.isSuccess) {
  // Payment successful — update order status
}
```

`CallbackResult` properties:

| Property            | Type     | Description                        |
|---------------------|----------|------------------------------------|
| `isSuccess`         | `bool`   | `true` when `RESPCODE == '1'`      |
| `orderNumber`       | `String` | Your original order ID             |
| `transactionNumber` | `String` | SADAD transaction reference        |
| `amount`            | `double` | Transaction amount                 |
| `responseCode`      | `String` | SADAD response code                |
| `responseMessage`   | `String` | Human-readable response message    |
| `status`            | `String` | Raw transaction status string      |

## Refunds

> **Important:** SADAD supports **full refunds only**. Partial refunds are not accepted. Refunds must be requested within **3 months** (90 days) of the original transaction date.

```dart
try {
  final result = await client.refund('TXN-123456789');

  if (result['success'] == true) {
    // Refund accepted
    print(result['refund_details']);
  }
} on RefundException catch (e) {
  // e.errorCode: REFUND_NOT_FOUND | REFUND_INVALID_STATUS
  //              | REFUND_EXPIRED | REFUND_ALREADY_DONE
  print('Refund failed: ${e.errorCode} — ${e.message}');
}
```

## Invoice Management

### Create an invoice

```dart
final result = await client.createInvoice({
  'cellnumber':     '97412345678',
  'clientname':     'Ahmed Al-Farsi',
  'remarks':        'Consulting services — March 2026',
  'amount':         500.00,
  'invoicedetails': [
    {'description': 'Consulting', 'amount': 500.00, 'quantity': 1},
  ],
});

if (result['success'] == true) {
  print(result['invoice_number']);
}
```

### Share an invoice

```dart
// Via email
await client.shareInvoice(invoiceNumber, 'email', 'client@example.com');

// Via SMS
await client.shareInvoice(invoiceNumber, 'sms', '97412345678');
```

### List invoices

```dart
final result = await client.listInvoices({
  'skip':  0,
  'limit': 20,
  'status': 2, // 2 = Unpaid
});

final invoices = result['invoices'];
```

## Transaction Lookup

```dart
final result = await client.getTransaction('TXN-123456789');

if (result['success'] == true) {
  print(result['transaction']);
}
```

## Error Handling

All SDK exceptions implement `SadadException`.

| Exception                 | Thrown when                                                   |
|---------------------------|---------------------------------------------------------------|
| `SadadException`          | Base exception — unexpected SDK errors                        |
| `AuthenticationException` | SADAD API login fails or returns no access token              |
| `SignatureException`      | Webhook or callback signature verification fails              |
| `RefundException`         | Refund eligibility check fails (invalid status, expired, etc) |

```dart
import 'package:sadad_qatar/sadad_qatar.dart';

try {
  final result = client.handleWebhook(payload);
} on SignatureException catch (e) {
  // Webhook signature invalid — reject the request
  print('Expected: ${e.expectedHash}');
  print('Received: ${e.receivedHash}');
} on SadadException catch (e) {
  print('SDK error [${e.errorCode}]: ${e.message}');
}
```

## Custom HTTP Client

Provide a custom [HttpClientInterface] for testing or custom networking:

```dart
class MyHttpClient implements HttpClientInterface {
  @override
  Future<Map<String, dynamic>> post(String url, {
    Map<String, dynamic> data = const {},
    Map<String, String> headers = const {},
  }) async { /* ... */ }

  @override
  Future<Map<String, dynamic>> get(String url, {
    Map<String, dynamic> params = const {},
    Map<String, String> headers = const {},
  }) async { /* ... */ }
}

final client = SadadClient(config, httpClient: MyHttpClient());
```

## Testing

```bash
dart test
```

The test suite covers config validation, signature generation and verification, AES encryption, salt generation, webhook and callback handling, and refund eligibility. All tests run against mock HTTP clients — no real SADAD credentials are required.

## Troubleshooting

**"Merchant ID must be exactly 7 digits"**
Ensure your merchant ID is exactly 7 numeric digits (e.g. `7015085`). Do not include spaces or dashes.

**"No access token in response"**
Check that your `merchantId`, `secretKey`, and `website` exactly match the values registered at [panel.sadad.qa](https://panel.sadad.qa). Also verify `environment` is `'test'` while testing.

**"Signature verification failed" on webhook/callback**
Confirm the `secretKey` in `SadadConfig` is identical to the key configured in the SADAD merchant panel. Ensure the raw POST body is passed without any modification.

**"Transaction is older than 3 months and cannot be refunded"**
SADAD only allows refunds within 90 days of the original transaction date.

## Bug Reports

Please open an issue on [GitHub Issues](https://github.com/louis-innovations/sadad-dart-sdk/issues) or email [info@louis-innovations.com](mailto:info@louis-innovations.com).

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a pull request.

## License

This project is licensed under the [MIT License](LICENSE).

---

Built by [Louis Innovations](https://www.louis-innovations.com)
