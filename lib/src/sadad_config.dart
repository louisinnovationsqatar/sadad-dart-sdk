// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

/// Configuration object for the SADAD payment gateway SDK.
///
/// Validates all parameters on construction and throws [ArgumentError]
/// if any parameter is invalid.
class SadadConfig {
  static const Map<String, String> _checkoutUrls = {
    'v1.1': 'https://sadadqa.com/webpurchase',
    'v2.1': 'https://sadadqa.com/webpurchase',
    'v2.2': 'https://secure.sadadqa.com/webpurchasepage',
  };

  static const String _apiBaseUrl = 'https://api-s.sadad.qa/api';

  static const List<String> _validEnvironments = ['test', 'live'];
  static const List<String> _validLanguages = ['eng', 'arb'];

  /// Your 7-digit SADAD merchant ID.
  final String merchantId;

  /// Your SADAD secret key.
  final String secretKey;

  /// Your website domain (e.g. `www.your-domain.com`).
  final String website;

  /// Gateway environment: `'test'` or `'live'`. Defaults to `'test'`.
  final String environment;

  /// Checkout page language: `'eng'` or `'arb'`. Defaults to `'eng'`.
  final String language;

  /// URL SADAD redirects the customer to after payment. Optional.
  final String? callbackUrl;

  /// URL SADAD posts payment notifications to. Optional.
  final String? webhookUrl;

  SadadConfig({
    required this.merchantId,
    required this.secretKey,
    required this.website,
    this.environment = 'test',
    this.language = 'eng',
    this.callbackUrl,
    this.webhookUrl,
  }) {
    _validate();
  }

  void _validate() {
    if (!RegExp(r'^\d{7}$').hasMatch(merchantId)) {
      throw ArgumentError('Merchant ID must be exactly 7 digits.');
    }

    if (secretKey.isEmpty) {
      throw ArgumentError('Secret key cannot be empty.');
    }

    if (!_validEnvironments.contains(environment)) {
      throw ArgumentError(
        'Environment must be one of: ${_validEnvironments.join(', ')}. Got: "$environment".',
      );
    }

    if (!_validLanguages.contains(language)) {
      throw ArgumentError(
        'Language must be one of: ${_validLanguages.join(', ')}. Got: "$language".',
      );
    }
  }

  /// Returns the checkout URL for the given [version] (`v1.1`, `v2.1`, or `v2.2`).
  ///
  /// Throws [ArgumentError] if [version] is not supported.
  String getCheckoutUrl(String version) {
    final url = _checkoutUrls[version];
    if (url == null) {
      throw ArgumentError(
        'Unknown checkout version "$version". Supported versions: ${_checkoutUrls.keys.join(', ')}.',
      );
    }
    return url;
  }

  /// Returns the base URL for the SADAD REST API.
  String getApiBaseUrl() => _apiBaseUrl;
}
