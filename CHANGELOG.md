# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-21

### Added
- Initial release
- `SadadConfig` with full validation (merchantId, secretKey, environment, language)
- Web Checkout v1.1 — Standard redirect with SHA-256 signature
- Web Checkout v2.1 — Enhanced redirect with AES-128-CBC encrypted checksum
- Web Checkout v2.2 — Embedded / iFrame checkout
- `CheckoutResult.toHtmlForm()` — generates auto-submitting HTML form
- SADAD API authentication with 1-hour token caching
- Invoice management: create, share via email or SMS, list with filters
- Full refund processing with eligibility validation
  - Status check (must be 3/Success)
  - Age check (within 90 days)
  - Duplicate refund check
- Transaction status lookup
- Webhook handler with SHA-256 signature verification
- Callback handler supporting v1.1, v2.1, v2.2
- `SignatureV1` — SHA-256 generation (SADAD v1.1 spec)
- `SignatureV2` — AES-128-CBC checksum generation (SADAD v2 spec)
- `SignatureVerifier` — verifyV1Callback, verifyWebhook, verifyV2Callback
- `AesEncryptor` — AES-128-CBC encrypt/decrypt with fixed SADAD IV
- `SaltGenerator` — 4-char cryptographic salt from SADAD charset
- Custom `HttpClientInterface` for dependency injection / testing
- `DartHttpClient` — default implementation using the `http` package
- Exception hierarchy: `SadadException`, `AuthenticationException`, `SignatureException`, `RefundException`
- Constant-time signature comparison to prevent timing attacks
- Comprehensive test suite
- Example usage in `example/example.dart`
