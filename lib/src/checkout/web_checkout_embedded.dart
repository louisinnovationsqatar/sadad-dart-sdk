// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'web_checkout_v2.dart';

/// SADAD Embedded (Secure) Checkout — v2.2
///
/// Identical to [WebCheckoutV2] in all respects except that it posts to the
/// secure embedded checkout URL (`v2.2`) rather than the standard `v2.1` URL.
class WebCheckoutEmbedded extends WebCheckoutV2 {
  @override
  String get checkoutVersion => 'v2.2';

  const WebCheckoutEmbedded(super.config);
}
