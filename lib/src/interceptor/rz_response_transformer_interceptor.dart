import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

/// A Dio [Interceptor] that automatically transforms string responses into
/// parsed JSON objects when the content type indicates JSON or the string
/// appears to be valid JSON.
///
/// This interceptor enhances the default Dio behavior by proactively parsing
/// responses that arrive as strings but are JSON-formatted, reducing boilerplate
/// in response handling. It only attempts parsing in debug mode if parsing fails,
/// logging the error without altering the response.
class RzResponseTransformerInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if response.data is a String and likely JSON
    if (response.data is String) {
      final contentType = response.headers.value('content-type');
      if (contentType?.contains('application/json') == true || _isJsonString(response.data)) {
        try {
          response.data = jsonDecode(response.data as String);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to parse JSON response: $e');
          }
          // Proceed with the original string data
        }
      }
    }
    handler.next(response);
  }

  /// Determines if a given [data] string appears to be a JSON object or array.
  ///
  /// This is a heuristic check: trims the string and verifies if it starts
  /// with '{' (object) or '[' (array). Used as a fallback when content-type
  /// is unavailable or ambiguous.
  ///
  /// - [data]: The data to check (must be a non-null [String]).
  ///
  /// Returns `true` if the string looks like JSON, `false` otherwise.
  bool _isJsonString(dynamic data) {
    if (data is! String) return false;
    final trimmed = (data).trim();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }
}