// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import '../sadad_config.dart';
import '../signature/signature_v1.dart';
import 'checkout_result.dart';

/// Builds the SADAD v1.1 web checkout (SHA-256 signature).
class WebCheckoutV1 {
  final SadadConfig _config;

  const WebCheckoutV1(this._config);

  /// Builds a [CheckoutResult] for the SADAD v1.1 web checkout flow.
  ///
  /// Required keys in [orderData]:
  ///   - `order_id`  — Unique merchant order ID.
  ///   - `amount`    — Total transaction amount.
  ///   - `mobile`    — Customer mobile number (digits stripped).
  ///   - `email`     — Customer email address.
  ///   - `items`     — List of maps, each with `order_id`, `amount`, `quantity`.
  ///
  /// Optional:
  ///   - `callback_url` — Overrides [SadadConfig.callbackUrl] for this order.
  CheckoutResult createCheckout(Map<String, dynamic> orderData) {
    final items = (orderData['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final callbackUrl =
        orderData['callback_url']?.toString() ?? _config.callbackUrl ?? '';

    // 1. Build core params
    final params = <String, dynamic>{
      'merchant_id': _config.merchantId,
      'ORDER_ID': orderData['order_id'].toString(),
      'WEBSITE': _config.website,
      'TXN_AMOUNT': _formatAmount(orderData['amount']),
      'CALLBACK_URL': callbackUrl,
      'MOBILE_NO': _stripNonDigits(orderData['mobile']?.toString() ?? ''),
      'EMAIL': orderData['email']?.toString() ?? '',
      'txnDate': _currentDateTime(),
      'SADAD_WEBCHECKOUT_PAGE_LANGUAGE': _config.language.toUpperCase(),
    };

    // 2. Add VERSION for multi-product (more than 1 item)
    if (items.length > 1) {
      params['VERSION'] = '1.1';
    }

    // 3. Generate SHA-256 signature (excludes productdetail)
    params['signature'] = SignatureV1.generate(params, _config.secretKey);

    // 4. Build productdetail array
    final productDetail = <Map<String, String>>[];
    for (final item in items) {
      productDetail.add({
        'order_id': item['order_id'].toString(),
        'amount': _formatAmount(item['amount']),
        'quantity': item['quantity'].toString(),
      });
    }

    if (productDetail.isNotEmpty) {
      params['productdetail'] = productDetail;
    }

    return CheckoutResult(
      url: _config.getCheckoutUrl('v1.1'),
      params: params,
    );
  }

  String _formatAmount(dynamic amount) {
    return (double.parse(amount.toString())).toStringAsFixed(2);
  }

  String _stripNonDigits(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  String _currentDateTime() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final mo = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final mi = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:$s';
  }
}
