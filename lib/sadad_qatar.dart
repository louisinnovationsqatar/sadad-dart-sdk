// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

/// Official Dart SDK for the SADAD Payment Gateway.
///
/// Import this library to access all public SDK classes:
///
/// ```dart
/// import 'package:sadad_qatar/sadad_qatar.dart';
///
/// final client = SadadClient(
///   SadadConfig(
///     merchantId: '1234567',
///     secretKey: 'your-secret-key',
///     website: 'www.your-domain.com',
///   ),
/// );
/// ```
library sadad_qatar;

// Core
export 'src/sadad_config.dart';
export 'src/sadad_client.dart';

// Checkout
export 'src/checkout/checkout_result.dart';
export 'src/checkout/web_checkout_v1.dart';
export 'src/checkout/web_checkout_v2.dart';
export 'src/checkout/web_checkout_embedded.dart';

// Signature
export 'src/signature/signature_v1.dart';
export 'src/signature/signature_v2.dart';
export 'src/signature/signature_verifier.dart';

// Encryption
export 'src/encryption/aes_encryptor.dart';
export 'src/encryption/salt_generator.dart';

// Auth
export 'src/auth/authenticator.dart';

// Invoice
export 'src/invoice/invoice_manager.dart';

// Refund
export 'src/refund/refund_manager.dart';

// Transaction
export 'src/transaction/transaction_manager.dart';

// Webhook
export 'src/webhook/webhook_handler.dart';
export 'src/webhook/webhook_result.dart';

// Callback
export 'src/callback/callback_handler.dart';
export 'src/callback/callback_result.dart';

// Errors
export 'src/errors/sadad_exception.dart';
export 'src/errors/authentication_exception.dart';
export 'src/errors/signature_exception.dart';
export 'src/errors/refund_exception.dart';

// HTTP
export 'src/http/http_client.dart';
