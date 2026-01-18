import 'package:dio/dio.dart';

/// A callback function invoked when an unauthorized (401) response is received.
///
/// This allows the application to handle authentication failures, such as
/// redirecting to a login screen or refreshing the token.
typedef UnauthorizedCallback = void Function();

/// A Dio [Interceptor] that automatically adds an Authorization Bearer token
/// header to outgoing requests and handles unauthorized (401) responses.
///
/// This interceptor enhances security by injecting authentication tokens into
/// requests when available and provides a hook for responding to expired or
/// invalid tokens via a callback. It is commonly used in authenticated API
/// clients to manage session-based access without manual header management
/// in each request.
class RzAuthInterceptor extends Interceptor {
  /// The authentication token to include in the Authorization header.
  ///
  /// If null or empty, no Authorization header is added to requests.
  final String? authToken;

  /// Optional callback invoked when a 401 Unauthorized response is received.
  ///
  /// Useful for triggering token refresh, logout, or navigation to login.
  final UnauthorizedCallback? onUnauthorized;

  /// The HTTP header key for the authorization (default: 'Authorization').
  final String authorization;

  /// The prefix for the Bearer token in the Authorization header (default: 'Bearer').
  final String bearerPrefix;

  /// Creates a new [RzAuthInterceptor] instance.
  ///
  /// - [authToken]: Optional initial authentication token.
  /// - [onUnauthorized]: Optional callback for handling 401 responses.
  /// - [authorization]: Optional custom header key (defaults to 'Authorization').
  /// - [bearerPrefix]: Optional prefix for the token (defaults to 'Bearer').
  RzAuthInterceptor({
    this.authToken,
    this.onUnauthorized,
    this.authorization = 'Authorization',
    this.bearerPrefix = 'Bearer',
  });

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    if (authToken != null && authToken!.trim().isNotEmpty) {
      options.headers[authorization] =
      '$bearerPrefix ${authToken!.trim()}';
    }
    handler.next(options);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}