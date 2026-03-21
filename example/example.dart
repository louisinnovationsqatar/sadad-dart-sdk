// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

// ignore_for_file: avoid_print

import 'package:sadad_qatar/sadad_qatar.dart';

Future<void> main() async {
  // ============================================================
  // 1. Configuration
  // ============================================================
  final config = SadadConfig(
    merchantId: '1234567', // Replace with your 7-digit SADAD merchant ID
    secretKey: 'your-secret-key', // Replace with your SADAD secret key
    website: 'www.your-domain.com',
    environment: 'test', // 'test' or 'live'
    language: 'eng', // 'eng' or 'arb'
    callbackUrl: 'https://www.your-domain.com/payment/callback',
    webhookUrl: 'https://www.your-domain.com/payment/webhook',
  );

  final client = SadadClient(config);

  // ============================================================
  // 2. Web Checkout v1.1 — SHA-256 signature redirect
  // ============================================================
  print('--- Web Checkout v1.1 ---');
  final orderData = {
    'order_id': 'ORD-2026-001',
    'amount': 150.00,
    'mobile': '97412345678',
    'email': 'customer@example.com',
    'items': [
      {'order_id': 'ORD-2026-001', 'amount': 150.00, 'quantity': 1},
    ],
  };

  final v1Result = client.checkout(orderData, 'v1.1');
  print('Checkout URL: ${v1Result.url}');
  print('Params: ${v1Result.params.keys.toList()}');
  print('\nHTML Form:\n${v1Result.toHtmlForm()}');

  // ============================================================
  // 3. Web Checkout v2.1 — AES-128-CBC encrypted checksum
  // ============================================================
  print('\n--- Web Checkout v2.1 ---');
  final v2Result = client.checkout(orderData, 'v2.1');
  print('Checkout URL: ${v2Result.url}');
  print('Has checksumhash: ${v2Result.params.containsKey('checksumhash')}');

  // ============================================================
  // 4. Web Checkout v2.2 — Embedded / iFrame checkout
  // ============================================================
  print('\n--- Web Checkout v2.2 (Embedded) ---');
  final v22Result = client.checkout(orderData, 'v2.2');
  print('Checkout URL: ${v22Result.url}');
  print('Form (no auto-submit):');
  print(v22Result.toHtmlForm(formId: 'sadad-frame', autoSubmit: false));

  // ============================================================
  // 5. Webhook handling
  // ============================================================
  print('\n--- Webhook Handling ---');

  // Simulate a webhook payload from SADAD
  final webhookParams = {
    'transaction_number': 'TXN-987654321',
    'ORDER_ID': 'ORD-2026-001',
    'TXN_AMOUNT': '150.00',
    'merchant_id': '1234567',
    'message': 'Payment successful',
    'transactionStatus': '3',
    'isTestMode': true,
  };

  // Generate a valid checksumhash (in production, SADAD sends this)
  final checksum = SignatureV1.generate(webhookParams, config.secretKey);
  webhookParams['checksumhash'] = checksum;

  try {
    final webhookResult = client.handleWebhook(webhookParams);
    if (webhookResult.isSuccess) {
      print('Payment confirmed!');
      print('  Transaction: ${webhookResult.transactionNumber}');
      print('  Order:       ${webhookResult.orderNumber}');
      print('  Amount:      QAR ${webhookResult.amount}');
      print('  Test mode:   ${webhookResult.isTestMode}');
    }

    // Respond to SADAD
    print('Webhook response: ${SadadClient.webhookSuccessResponse()}');
  } on SignatureException catch (e) {
    print('Webhook signature invalid: $e');
  }

  // ============================================================
  // 6. Payment callback handling
  // ============================================================
  print('\n--- Callback Handling ---');

  final callbackParams = {
    'ORDERID': 'ORD-2026-001',
    'transaction_number': 'TXN-987654321',
    'TXNAMOUNT': '150.00',
    'RESPCODE': '1',
    'RESPMSG': 'Transaction Successful',
    'STATUS': 'TXN_SUCCESS',
  };

  final callbackHash = SignatureV1.generate(callbackParams, config.secretKey);
  callbackParams['checksumhash'] = callbackHash;

  try {
    final callbackResult = client.handleCallback(callbackParams, 'v1.1');
    if (callbackResult.isSuccess) {
      print('Payment successful — order: ${callbackResult.orderNumber}');
      print('  Transaction: ${callbackResult.transactionNumber}');
      print('  Amount:      QAR ${callbackResult.amount}');
      print('  Status:      ${callbackResult.status}');
    }
  } on SignatureException catch (e) {
    print('Callback signature invalid: $e');
  }

  // ============================================================
  // 7. AES encryption (direct access)
  // ============================================================
  print('\n--- AES Encryption ---');
  const plaintext = 'Hello, SADAD!';
  const key = 'my-secret-key-16';
  final encrypted = AesEncryptor.encrypt(plaintext, key);
  final decrypted = AesEncryptor.decrypt(encrypted, key);
  print('Plaintext:  $plaintext');
  print('Encrypted:  $encrypted');
  print('Decrypted:  $decrypted');

  // ============================================================
  // 8. Salt generation
  // ============================================================
  print('\n--- Salt Generation ---');
  for (var i = 0; i < 5; i++) {
    print('Salt ${i + 1}: ${SaltGenerator.generate()}');
  }

  // ============================================================
  // 9. API operations (requires valid credentials)
  // ============================================================
  print('\n--- API Operations (requires live credentials) ---');
  print('The following operations require valid SADAD credentials:');

  // Create an invoice
  // final invoiceResult = await client.createInvoice({
  //   'cellnumber': '97412345678',
  //   'clientname': 'Ahmed Al-Farsi',
  //   'remarks': 'Consulting services — March 2026',
  //   'amount': 500.00,
  //   'invoicedetails': [
  //     {'description': 'Consulting', 'amount': 500.00, 'quantity': 1},
  //   ],
  // });
  // print('Invoice: $invoiceResult');

  // Share an invoice
  // final shareResult = await client.shareInvoice('INV-001', 'email', 'client@example.com');
  // print('Share: $shareResult');

  // List invoices
  // final listResult = await client.listInvoices({'skip': 0, 'limit': 10});
  // print('Invoices: $listResult');

  // Get transaction
  // final txnResult = await client.getTransaction('TXN-987654321');
  // print('Transaction: $txnResult');

  // Refund a transaction
  // try {
  //   final refundResult = await client.refund('TXN-987654321');
  //   print('Refund: $refundResult');
  // } on RefundException catch (e) {
  //   print('Refund failed: ${e.errorCode} — ${e.message}');
  // }

  print('\nExample complete.');
}
