// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

/// The result of building a SADAD checkout session.
///
/// Contains the target [url] and all required [params] to submit to the
/// SADAD gateway. Use [toHtmlForm] to generate a ready-to-render HTML form.
class CheckoutResult {
  /// The checkout URL (form action).
  final String url;

  /// All checkout parameters including the signature or checksum.
  final Map<String, dynamic> params;

  const CheckoutResult({
    required this.url,
    required this.params,
  });

  /// Generates an HTML form that posts all checkout parameters to the SADAD gateway.
  ///
  /// Nested maps (e.g. `productdetail`) are expanded into indexed hidden inputs:
  ///   `productdetail[0][order_id]`, `productdetail[0][amount]`, etc.
  ///
  /// [formId] sets the `id` attribute on the `<form>` element.
  /// [autoSubmit] appends a JavaScript auto-submit snippet when `true`.
  String toHtmlForm({
    String formId = 'sadad-checkout-form',
    bool autoSubmit = true,
  }) {
    final inputs = _buildInputs(params);
    final escapedFormId = _escapeHtml(formId);
    final escapedUrl = _escapeHtml(url);

    final buffer = StringBuffer();
    buffer.writeln('<form id="$escapedFormId" method="POST" action="$escapedUrl">');

    for (final input in inputs) {
      final name = _escapeHtml(input.$1);
      final value = _escapeHtml(input.$2.toString());
      buffer.writeln('    <input type="hidden" name="$name" value="$value">');
    }

    buffer.write('</form>');

    if (autoSubmit) {
      buffer.writeln();
      buffer.write(
        '<script>document.getElementById("$escapedFormId").submit();</script>',
      );
    }

    return buffer.toString();
  }

  /// Recursively flattens [params] into `(name, value)` pairs for hidden inputs.
  List<(String, dynamic)> _buildInputs(
    Map<String, dynamic> params, [
    String prefix = '',
  ]) {
    final inputs = <(String, dynamic)>[];

    for (final entry in params.entries) {
      final inputName =
          prefix.isEmpty ? entry.key : '$prefix[${entry.key}]';

      if (entry.value is Map<String, dynamic>) {
        inputs.addAll(
          _buildInputs(entry.value as Map<String, dynamic>, inputName),
        );
      } else if (entry.value is List) {
        final list = entry.value as List;
        for (var i = 0; i < list.length; i++) {
          final item = list[i];
          if (item is Map<String, dynamic>) {
            inputs.addAll(_buildInputs(item, '$inputName[$i]'));
          } else {
            inputs.add(('$inputName[$i]', item));
          }
        }
      } else {
        inputs.add((inputName, entry.value));
      }
    }

    return inputs;
  }

  String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}
