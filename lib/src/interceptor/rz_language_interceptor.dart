import 'package:dio/dio.dart';

/// A Dio [Interceptor] that automatically adds a language header to all outgoing
/// requests, allowing for localization of API responses based on the client's
/// preferred language.
///
/// This interceptor injects the specified language code (e.g., 'en-US', 'fr') into
/// the request headers using a configurable header key (default: 'Accept-Language').
/// It is useful for applications that support multiple languages and need to
/// communicate language preferences to the backend server.
class RzLanguageInterceptor extends Interceptor {
  /// The HTTP header key used to specify the language (default: 'Accept-Language').
  final String header;

  /// The language code to include in the request headers (e.g., 'en', 'fr-FR').
  final String language;

  /// Creates a new [RzLanguageInterceptor] instance.
  ///
  /// - [language]: The required language code to set in the headers.
  /// - [header]: Optional custom header key (defaults to 'Accept-Language').
  RzLanguageInterceptor(this.language, {this.header = 'Accept-Language'});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[header] = language;
    handler.next(options);
  }
}
