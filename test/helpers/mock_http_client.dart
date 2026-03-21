// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'package:sadad_qatar/sadad_qatar.dart';

/// A mock [HttpClientInterface] for unit tests.
///
/// Set [onPost] and [onGet] to control the responses returned by
/// each method.
class MockHttpClient implements HttpClientInterface {
  /// Override this to control POST responses.
  Future<Map<String, dynamic>> Function(
    String url,
    Map<String, dynamic> data,
    Map<String, String> headers,
  )? onPost;

  /// Override this to control GET responses.
  Future<Map<String, dynamic>> Function(
    String url,
    Map<String, dynamic> params,
    Map<String, String> headers,
  )? onGet;

  /// Records all POST calls made.
  final List<(String, Map<String, dynamic>, Map<String, String>)> postCalls =
      [];

  /// Records all GET calls made.
  final List<(String, Map<String, dynamic>, Map<String, String>)> getCalls =
      [];

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic> data = const {},
    Map<String, String> headers = const {},
  }) async {
    postCalls.add((url, data, headers));
    final handler = onPost;
    if (handler != null) {
      return handler(url, data, headers);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic> params = const {},
    Map<String, String> headers = const {},
  }) async {
    getCalls.add((url, params, headers));
    final handler = onGet;
    if (handler != null) {
      return handler(url, params, headers);
    }
    return {};
  }

  /// Resets all recorded calls and handlers.
  void reset() {
    postCalls.clear();
    getCalls.clear();
    onPost = null;
    onGet = null;
  }
}
