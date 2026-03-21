// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import '../auth/authenticator.dart';
import '../http/http_client.dart';
import '../sadad_config.dart';

/// Manages SADAD invoices: create, share, and list.
class InvoiceManager {
  /// `sentvia` value for email sharing.
  static const int _shareViaEmail = 3;

  /// `sentvia` value for SMS sharing.
  static const int _shareViaSms = 4;

  /// Default invoice status: Unpaid.
  static const int _statusUnpaid = 2;

  /// Default country code for Qatar.
  static const int _defaultCountryCode = 974;

  final SadadConfig _config;
  final HttpClientInterface _httpClient;
  final Authenticator _authenticator;

  InvoiceManager(this._config, this._httpClient, this._authenticator);

  /// Creates a new invoice.
  ///
  /// Expected keys in [data]:
  ///   - `cellnumber`     — Customer mobile number (digits stripped).
  ///   - `clientname`     — Customer name.
  ///   - `remarks`        — Invoice remarks / description.
  ///   - `amount`         — Invoice total amount.
  ///   - `invoicedetails` — List of line items.
  ///   - `countryCode`    — (optional) Defaults to 974.
  ///   - `status`         — (optional) Defaults to 2 (Unpaid).
  ///
  /// Returns a map with `success`, `invoice_number`, `invoice_id`, and `data`
  /// on success, or `success: false` and `error` on failure.
  Future<Map<String, dynamic>> createInvoice(Map<String, dynamic> data) async {
    try {
      final token = await _authenticator.getAccessToken();

      final cellnumber = (data['cellnumber']?.toString() ?? '')
          .replaceAll(RegExp(r'\D'), '');

      final payload = <String, dynamic>{
        'countryCode': (data['countryCode'] as int?) ?? _defaultCountryCode,
        'cellnumber': cellnumber,
        'clientname': data['clientname']?.toString() ?? '',
        'status': (data['status'] as int?) ?? _statusUnpaid,
        'remarks': data['remarks']?.toString() ?? '',
        'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
        'invoicedetails': data['invoicedetails'] ?? <dynamic>[],
      };

      final response = await _httpClient.post(
        '${_config.getApiBaseUrl()}/invoices/createInvoice',
        data: payload,
        headers: {'Authorization': 'Bearer $token'},
      );

      return {
        'success': true,
        'invoice_number':
            response['invoiceNumber'] ?? response['invoice_number'],
        'invoice_id': response['invoiceId'] ?? response['invoice_id'],
        'data': response,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Shares an existing invoice via email or SMS.
  ///
  /// [invoiceNumber] — The invoice number to share.
  /// [method]        — `'email'` or `'sms'`.
  /// [recipient]     — Email address or mobile number.
  ///
  /// Returns a map with `success` and `message` on success, or `error` on failure.
  Future<Map<String, dynamic>> shareInvoice(
    String invoiceNumber,
    String method,
    String recipient,
  ) async {
    try {
      final token = await _authenticator.getAccessToken();
      final isEmail = method.toLowerCase() == 'email';

      final payload = <String, dynamic>{
        'invoiceNumber': invoiceNumber,
        'sentvia': isEmail ? _shareViaEmail : _shareViaSms,
      };

      if (isEmail) {
        payload['receiverEmail'] = recipient;
      } else {
        payload['receivercellno'] =
            recipient.replaceAll(RegExp(r'\D'), '');
      }

      final response = await _httpClient.post(
        '${_config.getApiBaseUrl()}/invoices/share',
        data: payload,
        headers: {'Authorization': 'Bearer $token'},
      );

      return {
        'success': true,
        'message': response['message']?.toString() ??
            'Invoice shared successfully.',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Lists invoices with optional filters.
  ///
  /// Supported keys in [filters]:
  ///   - `skip`, `limit`, `status`, `clientname`, `invoicenumber`, `date`
  ///
  /// Returns a map with `success` and `invoices` on success, or `error` on failure.
  Future<Map<String, dynamic>> listInvoices([
    Map<String, dynamic> filters = const {},
  ]) async {
    try {
      final token = await _authenticator.getAccessToken();

      final params = <String, dynamic>{};
      const supportedFilters = [
        'skip',
        'limit',
        'status',
        'clientname',
        'invoicenumber',
        'date',
      ];

      for (final key in supportedFilters) {
        if (filters.containsKey(key)) {
          params['filter[$key]'] = filters[key];
        }
      }

      final response = await _httpClient.get(
        '${_config.getApiBaseUrl()}/invoices/listInvoices',
        params: params,
        headers: {'Authorization': 'Bearer $token'},
      );

      return {
        'success': true,
        'invoices': response['invoices'] ?? response['data'] ?? response,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
