// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'auth/authenticator.dart';
import 'callback/callback_handler.dart';
import 'callback/callback_result.dart';
import 'checkout/checkout_result.dart';
import 'checkout/web_checkout_embedded.dart';
import 'checkout/web_checkout_v1.dart';
import 'checkout/web_checkout_v2.dart';
import 'http/http_client.dart';
import 'invoice/invoice_manager.dart';
import 'refund/refund_manager.dart';
import 'sadad_config.dart';
import 'transaction/transaction_manager.dart';
import 'webhook/webhook_handler.dart';
import 'webhook/webhook_result.dart';

/// Main facade for the SADAD Payment Gateway SDK.
///
/// Instantiate with a [SadadConfig] to access all gateway features.
///
/// ```dart
/// final client = SadadClient(
///   SadadConfig(
///     merchantId: '1234567',
///     secretKey: 'your-secret-key',
///     website: 'www.your-domain.com',
///   ),
/// );
/// ```
class SadadClient {
  final SadadConfig _config;
  final HttpClientInterface _httpClient;
  late final Authenticator _authenticator;
  late final TransactionManager _transactionManager;
  late final InvoiceManager _invoiceManager;
  late final RefundManager _refundManager;
  late final WebhookHandler _webhookHandler;
  late final CallbackHandler _callbackHandler;

  SadadClient(SadadConfig config, {HttpClientInterface? httpClient})
      : _config = config,
        _httpClient = httpClient ?? DartHttpClient() {
    _authenticator = Authenticator(_config, _httpClient);
    _transactionManager =
        TransactionManager(_config, _httpClient, _authenticator);
    _invoiceManager =
        InvoiceManager(_config, _httpClient, _authenticator);
    _refundManager = RefundManager(
      _config,
      _httpClient,
      _authenticator,
      _transactionManager,
    );
    _webhookHandler = WebhookHandler(_config);
    _callbackHandler = CallbackHandler(_config);
  }

  /// Creates a checkout session for the given [orderData] and [version].
  ///
  /// Supported [version] values: `'v1.1'`, `'v2.1'`, `'v2.2'`.
  ///
  /// Throws [ArgumentError] for an unsupported [version].
  CheckoutResult checkout(
    Map<String, dynamic> orderData, [
    String version = 'v1.1',
  ]) {
    return switch (version) {
      'v1.1' => WebCheckoutV1(_config).createCheckout(orderData),
      'v2.1' => WebCheckoutV2(_config).createCheckout(orderData),
      'v2.2' => WebCheckoutEmbedded(_config).createCheckout(orderData),
      _ => throw ArgumentError('Invalid checkout version: $version'),
    };
  }

  /// Processes an incoming SADAD webhook [payload].
  ///
  /// Throws [SignatureException] if signature verification fails.
  WebhookResult handleWebhook(Map<String, dynamic> payload) {
    return _webhookHandler.handle(payload);
  }

  /// Processes a SADAD payment callback [postData].
  ///
  /// [version] must be `'v1.1'`, `'v2.1'`, or `'v2.2'`.
  ///
  /// Throws [SignatureException] if signature verification fails.
  CallbackResult handleCallback(
    Map<String, dynamic> postData, [
    String version = 'v1.1',
  ]) {
    return _callbackHandler.handle(postData, version);
  }

  /// Creates a new SADAD invoice. See [InvoiceManager.createInvoice].
  Future<Map<String, dynamic>> createInvoice(
    Map<String, dynamic> data,
  ) {
    return _invoiceManager.createInvoice(data);
  }

  /// Shares an existing invoice via email or SMS. See [InvoiceManager.shareInvoice].
  Future<Map<String, dynamic>> shareInvoice(
    String invoiceNumber,
    String method,
    String recipient,
  ) {
    return _invoiceManager.shareInvoice(invoiceNumber, method, recipient);
  }

  /// Lists invoices with optional filters. See [InvoiceManager.listInvoices].
  Future<Map<String, dynamic>> listInvoices([
    Map<String, dynamic> filters = const {},
  ]) {
    return _invoiceManager.listInvoices(filters);
  }

  /// Issues a full refund for [transactionNumber]. See [RefundManager.refund].
  ///
  /// Throws [RefundException] if the transaction is not eligible for refund.
  Future<Map<String, dynamic>> refund(String transactionNumber) {
    return _refundManager.refund(transactionNumber);
  }

  /// Retrieves transaction details. See [TransactionManager.getTransaction].
  Future<Map<String, dynamic>> getTransaction(String transactionNumber) {
    return _transactionManager.getTransaction(transactionNumber);
  }

  /// Returns the standard webhook success acknowledgement map.
  static Map<String, String> webhookSuccessResponse() {
    return WebhookHandler.successResponse();
  }
}
