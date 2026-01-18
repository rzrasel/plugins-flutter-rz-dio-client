import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import '../client/rz_dio_client_obj.dart';

/// A singleton provider for managing Dio HTTP client instances, handling
/// authentication, configuration, and common HTTP operations.
///
/// This class acts as a centralized service for API requests in Flutter applications,
/// providing a reusable Dio instance with built-in support for authentication tokens,
/// interceptors, timeouts, and content types. It ensures a single instance is used
/// throughout the app lifecycle, with options to reset on events like logout.
class RzDioProvider {
  /// The singleton instance of [RzDioProvider].
  static RzDioProvider? _instance;

  /// The underlying Dio HTTP client instance.
  late final dio.Dio _dio;

  /// Private constructor for internal instantiation.
  ///
  /// Initializes the Dio client with the provided configuration.
  ///
  /// - [authToken]: Optional initial authentication token.
  /// - [onUnauthorized]: Optional callback invoked on unauthorized responses (e.g., 401).
  /// - [baseUrl]: Optional base URL for the Dio client.
  RzDioProvider._internal({
    String? authToken,
    VoidCallback? onUnauthorized,
    String? baseUrl,
  }) {
    _dio = RzDioClient.buildClient(
      authToken: authToken,
      onUnauthorized: onUnauthorized,
      baseUrl: baseUrl,
    );
    // Set default responseType globally
    _dio.options.responseType = dio.ResponseType.json;
  }

  /// Factory constructor for accessing the singleton instance.
  ///
  /// Creates a new instance if none exists, otherwise returns the existing one.
  ///
  /// - [authToken]: Optional initial authentication token.
  /// - [onUnauthorized]: Optional callback for unauthorized responses.
  /// - [baseUrl]: Optional base URL.
  ///
  /// Returns the singleton [RzDioProvider] instance.
  factory RzDioProvider({
    String? authToken,
    VoidCallback? onUnauthorized,
    String? baseUrl,
  }) {
    _instance ??= RzDioProvider._internal(
      authToken: authToken,
      onUnauthorized: onUnauthorized,
      baseUrl: baseUrl,
    );
    return _instance!;
  }

  // Content Type: application/json - multipart/form-data
  /// Sets the default content type for requests.
  ///
  /// Proxies to [RzDioClient.setContentType] for global configuration.
  ///
  /// - [contentType]: The content type to set (default: "application/json").
  static void setContentType({String contentType = "application/json"}) {
    RzDioClient.setContentType(contentType: contentType);
  }

  /// Sets custom interceptors for the Dio client.
  ///
  /// Call this before instantiating [RzDioProvider] to configure request/response logging,
  /// authentication, or other middleware.
  ///
  /// - [interceptors]: The list of Dio interceptors to add.
  static void setInterceptors(dynamic interceptors) {
    RzDioClient.setInterceptors(interceptors);
  }

  /// Sets timeout configurations for the Dio client.
  ///
  /// Proxies to [RzDioClient.setTimeout] for global timeout settings.
  ///
  /// - [connectTimeout]: Connection timeout in milliseconds (optional).
  /// - [receiveTimeout]: Receive timeout in milliseconds (optional).
  /// - [sendTimeout]: Send timeout in milliseconds (optional).
  static void setTimeout({
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
  }) {
    RzDioClient.setTimeout(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    );
  }

  /// Dynamically sets the authentication token and bearer prefix.
  ///
  /// Updates the underlying Dio client with the new token for subsequent requests.
  ///
  /// - [token]: The new authentication token (null to clear).
  /// - [bearerPrefix]: The prefix for the token (default: 'Bearer').
  ///
  /// Returns `this` for method chaining.
  RzDioProvider setAuth(String? token, {String bearerPrefix = 'Bearer'}) {
    RzDioClient.setAuth(token, bearerPrefix: bearerPrefix);
    return this;
  }

  /// Dynamically sets the authentication token and bearer prefix (alias for [setAuth]).
  ///
  /// Updates the underlying Dio client with the new token for subsequent requests.
  ///
  /// - [token]: The new authentication token (null to clear).
  /// - [bearerPrefix]: The prefix for the token (default: 'Bearer').
  ///
  /// Returns `this` for method chaining.
  RzDioProvider setToken(String? token, {String bearerPrefix = 'Bearer'}) {
    RzDioClient.setAuth(token, bearerPrefix: bearerPrefix);
    return this;
  }

  /// Creates a new [CancelToken] for request cancellation.
  ///
  /// Useful for long-running requests that may need to be aborted.
  ///
  /// Returns a fresh [dio.CancelToken] instance.
  static dio.CancelToken createCancelToken() {
    return dio.CancelToken();
  }

  /// Resets the singleton instance to null.
  ///
  /// Useful for scenarios like user logout, where a fresh instance with new
  /// configuration (e.g., no auth token) is needed on next instantiation.
  static void reset() {
    _instance = null;
  }

  /* --------------------------------------------------------------------------
   * HTTP METHODS
   * -------------------------------------------------------------------------- */
  /// Performs an HTTP GET request.
  ///
  /// - [path]: The endpoint path (relative to base URL).
  /// - [queryParameters]: Optional query parameters as a map.
  /// - [options]: Optional [dio.Options] for custom headers, etc.
  /// - [cancelToken]: Optional [dio.CancelToken] for cancellation.
  ///
  /// Returns a [Future] that resolves to the [dio.Response<T>].
  Future<dio.Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        dio.Options? options,
        dio.CancelToken? cancelToken,
      }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs an HTTP POST request.
  ///
  /// - [path]: The endpoint path (relative to base URL).
  /// - [data]: Optional request body data.
  /// - [queryParameters]: Optional query parameters as a map.
  /// - [options]: Optional [dio.Options] for custom headers, etc.
  /// - [cancelToken]: Optional [dio.CancelToken] for cancellation.
  ///
  /// Returns a [Future] that resolves to the [dio.Response<T>].
  Future<dio.Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        dio.Options? options,
        dio.CancelToken? cancelToken,
      }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs an HTTP PUT request.
  ///
  /// - [path]: The endpoint path (relative to base URL).
  /// - [data]: Optional request body data.
  /// - [queryParameters]: Optional query parameters as a map.
  /// - [options]: Optional [dio.Options] for custom headers, etc.
  /// - [cancelToken]: Optional [dio.CancelToken] for cancellation.
  ///
  /// Returns a [Future] that resolves to the [dio.Response<T>].
  Future<dio.Response<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        dio.Options? options,
        dio.CancelToken? cancelToken,
      }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Performs an HTTP DELETE request.
  ///
  /// - [path]: The endpoint path (relative to base URL).
  /// - [data]: Optional request body data (for DELETE with body).
  /// - [queryParameters]: Optional query parameters as a map.
  /// - [options]: Optional [dio.Options] for custom headers, etc.
  /// - [cancelToken]: Optional [dio.CancelToken] for cancellation.
  ///
  /// Returns a [Future] that resolves to the [dio.Response<T>].
  Future<dio.Response<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        dio.Options? options,
        dio.CancelToken? cancelToken,
      }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}