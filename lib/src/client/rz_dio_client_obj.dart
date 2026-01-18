import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../interceptor/rz_auth_interceptor.dart';

/// A singleton-based Dio client factory and configuration manager for Flutter
/// applications.
///
/// This class provides a centralized way to build, configure, and manage a Dio
/// HTTP client instance with support for authentication, custom interceptors,
/// timeouts, content types, and platform-specific behaviors (e.g., disabling
/// sendTimeout on web). It ensures a single Dio instance is reused across the
/// app, reducing overhead, while offering static methods to dynamically update
/// configurations without reinstantiation.
class RzDioClient {
  /// Default connection timeout in milliseconds (300 seconds).
  static int connectTimeout = 300000;

  /// Default receive timeout in milliseconds (300 seconds).
  static int receiveTimeout = 300000;

  /// Default send timeout in milliseconds (300 seconds), nullable for web compatibility.
  ///
  /// On web platforms, sendTimeout is automatically set to null as it is not supported.
  static int? sendTimeout = 300000;

  /// Default content type for requests (e.g., 'application/json').
  static String contentType = 'application/json';

  /// List of custom interceptors to apply to the Dio instance.
  ///
  /// Can be set via [setInterceptors] before building the client.
  static List<Interceptor> interceptors = [];

  /// Internal callback for handling unauthorized (401) responses.
  static VoidCallback? _onUnauthorized;

  /// Internal Dio instance reference.
  static Dio? _dio;

  /// Getter for the singleton Dio instance.
  ///
  /// Lazily initializes the instance via [buildClient] if not already created.
  ///
  /// Returns the configured [Dio] instance.
  static Dio get instance {
    _dio ??= buildClient();
    return _dio!;
  }

  /// Builds and configures a new Dio client instance.
  ///
  /// This is the core factory method for creating the Dio client with the
  /// current static configurations (timeouts, content type, etc.). It adds
  /// default headers, response type, and optional auth interceptor. Custom
  /// interceptors from [interceptors] are also applied.
  ///
  /// - [authToken]: Optional initial authentication token for the auth interceptor.
  /// - [onUnauthorized]: Optional callback for 401 responses.
  /// - [baseUrl]: Optional base URL to set on the Dio options.
  ///
  /// Returns the built [Dio] instance. If already built, returns the existing one.
  static Dio buildClient({
    String? authToken,
    VoidCallback? onUnauthorized,
    String? baseUrl,
  }) {
    if (_dio != null) return _dio!;
    _onUnauthorized = onUnauthorized;
    final options = BaseOptions(
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      // Web-safe sendTimeout
      sendTimeout: _resolveSendTimeout(),
      headers: {
        'Content-Type': contentType,
        'Accept': contentType,
      },
      responseType: ResponseType.json,
    );
    debugPrint("===========$baseUrl=========");
    // Set baseUrl only if it's not null
    if (baseUrl != null && baseUrl.isNotEmpty) {
      options.baseUrl = baseUrl;
    }
    final dio = Dio(options);
    if (authToken != null || onUnauthorized != null) {
      dio.interceptors.add(
          RzAuthInterceptor(
            authToken: authToken,
            onUnauthorized: onUnauthorized,
          )
      );
    }
    // if not empty interceptors add interceptors
    if (interceptors.isNotEmpty) {
      dio.interceptors.addAll(interceptors);
    }
    _dio = dio;
    return dio;
  }

  /// Dynamically sets the content type for requests.
  ///
  /// Updates the static [contentType] and applies it to the existing Dio
  /// instance's options and headers if available.
  ///
  /// - [contentType]: The new content type (default: "application/json").
  static void setContentType({String contentType = "application/json"}) {
    RzDioClient.contentType = contentType;
    final dio = _dio;
    if (dio == null) return;
    // Update Dio options
    dio.options.contentType = contentType;
    dio.options.headers['Content-Type'] = contentType;
    dio.options.headers['Accept'] = contentType;
  }

  /// Sets custom interceptors for the Dio client.
  ///
  /// Accepts a single [Interceptor] or [List<Interceptor>]. Replaces any
  /// existing interceptors of the same runtime type in the current Dio instance.
  ///
  /// - [interceptors]: The interceptor(s) to add (single or list).
  static void setInterceptors(dynamic interceptors) {
    List<Interceptor> toAdd = [];
    if (interceptors is Interceptor) {
      toAdd.add(interceptors);
    } else if (interceptors is List) {
      toAdd.addAll(interceptors.cast<Interceptor>());
    }
    RzDioClient.interceptors = toAdd;
    final dio = _dio;
    if (dio != null) {
      for (final interceptor in toAdd) {
        dio.interceptors.removeWhere(
              (e) => e.runtimeType == interceptor.runtimeType,
        );
        dio.interceptors.add(interceptor);
      }
    }
  }

  /// Dynamically sets timeout configurations.
  ///
  /// Updates the static timeout values and applies them to the existing Dio
  /// instance if available. Send timeout is disabled on web platforms.
  ///
  /// - [connectTimeout]: Optional connection timeout in milliseconds.
  /// - [receiveTimeout]: Optional receive timeout in milliseconds.
  /// - [sendTimeout]: Optional send timeout in milliseconds (ignored on web).
  static void setTimeout({
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
  }) {
    if (connectTimeout != null) {
      RzDioClient.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      RzDioClient.receiveTimeout = receiveTimeout;
    }
    // Force-disable sendTimeout on Web
    RzDioClient.sendTimeout = kIsWeb ? null : sendTimeout;
  }

  /// Dynamically sets the authentication token and bearer prefix.
  ///
  /// Removes any existing [RzAuthInterceptor] and adds a new one with the
  /// provided token and callback. Does nothing if token is null or empty.
  ///
  /// - [token]: The new authentication token.
  /// - [bearerPrefix]: The prefix for the Bearer token (default: 'Bearer').
  static void setAuth(String? token, {String bearerPrefix = 'Bearer'}) {
    final dio = instance;
    // Remove old auth interceptor if exists
    dio.interceptors.removeWhere((element) => element is RzAuthInterceptor);
    if (token != null && token.trim().isNotEmpty) {
      dio.interceptors.add(
        RzAuthInterceptor(
          authToken: token,
          bearerPrefix: bearerPrefix,
          onUnauthorized: _onUnauthorized,
        ),
      );
    }
  }

  /// Resolves the send timeout duration in a web-safe manner.
  ///
  /// Returns null if on web or if [sendTimeout] is null; otherwise, returns
  /// a [Duration] based on [sendTimeout].
  ///
  /// Returns a nullable [Duration].
  static Duration? _resolveSendTimeout() {
    if (kIsWeb) return null;
    if (sendTimeout == null) return null;
    return Duration(milliseconds: sendTimeout!);
  }

  /// Clears the authentication by removing the [RzAuthInterceptor].
  ///
  /// Does nothing if no Dio instance exists or no auth interceptor is present.
  static void clearAuth() {
    final dio = _dio;
    if (dio == null) return;
    dio.interceptors.removeWhere((e) => e is RzAuthInterceptor);
  }
}