/ File: rz_cancel_token_manager.dart **/

import 'package:dio/dio.dart';

class RzCancelTokenManager {
  CancelToken? _token;

  CancelToken get token {
    _token ??= CancelToken();
    return _token!;
  }

  void cancel([String reason = 'Request cancelled']) {
    if (_token != null && !_token!.isCancelled) {
      _token!.cancel(reason);
    }
    _token = null;
  }

  void reset() {
    _token = null;
  }
}

/ File: rz_dio_client_obj.dart **/

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../interceptor/rz_auth_interceptor.dart';

class RzDioClient {
  static int connectTimeout = 300000;
  static int receiveTimeout = 300000;
  static int? sendTimeout = 300000;
  static String contentType = 'application/json';
  static List<Interceptor> interceptors = [];
  static VoidCallback? _onUnauthorized;

  static Dio? _dio;

  static Dio get instance {
    _dio ??= buildClient();
    return _dio!;
  }

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

    print("===========$baseUrl=========");
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

  static void setContentType({String contentType = "application/json"}) {
    RzDioClient.contentType = contentType;
    final dio = _dio;
    if (dio == null) return;

    // Update Dio options
    dio.options.contentType = contentType;
    dio.options.headers['Content-Type'] = contentType;
    dio.options.headers['Accept'] = contentType;
  }

  // Static method to set the static interceptors list
  // Accepts single Interceptor or List<Interceptor>
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

  // Static method to set timeouts dynamically
  // Accepts optional named parameters for connect, read, and write timeouts in milliseconds
  static void setTimeout({
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout = null,
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

  /// Web-safe resolver
  static Duration? _resolveSendTimeout() {
    if (kIsWeb) return null;
    if (sendTimeout == null) return null;
    return Duration(milliseconds: sendTimeout!);
  }

  static void clearAuth() {
    final dio = _dio;
    if (dio == null) return;
    dio.interceptors.removeWhere((e) => e is RzAuthInterceptor);
  }
}

/ File: rz_auth_interceptor.dart **/

import 'package:dio/dio.dart';

typedef UnauthorizedCallback = void Function();

class RzAuthInterceptor extends Interceptor {
  final String? authToken;
  final UnauthorizedCallback? onUnauthorized;
  final String authorization;
  final String bearerPrefix;

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


/ File: rz_dio_printer_interceptor.dart **/

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

void printer(dynamic value) {
  if (kDebugMode) {
    debugPrint(value.toString());
  }
}

class RzDioPrinterInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    printer("= = = DIO REQUEST = = =");
    printer("METHOD       : ${options.method}");
    printer("URL          : ${options.baseUrl}${options.path}");
    printer("HEADERS      : ${options.headers}");
    printer("CONTENT_TYPE : ${options.contentType}");
    printer("QUERY        : ${options.queryParameters}");
    printer("EXTRA        : ${options.extra}");
    printer("BODY         : ${options.data}");
    printer("==========================");

    handler.next(options);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    printer("= = = DIO RESPONSE = = =");
    printer("URL         : ${response.requestOptions.baseUrl}${response.requestOptions.path}");
    printer("STATUS CODE : ${response.statusCode}");
    printer("HEADERS     : ${response.headers}");
    printer("EXTRA       : ${response.extra}");
    printer("DATA        : ${jsonEncode(response.data)}");
    printer("==========================");

    handler.next(response);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    printer("= = = DIO ERROR = = =");
    printer("URL         : ${err.requestOptions.baseUrl}${err.requestOptions.path}");
    printer("TYPE        : ${err.type}");
    printer("MESSAGE     : ${err.message}");
    printer("STATUS CODE : ${err.response?.statusCode}");
    printer("RESPONSE    : ${err.response?.data}");
    printer("==========================");

    handler.next(err);
  }
}

/ File: rz_language_interceptor.dart **/

import 'package:dio/dio.dart';

class RzLanguageInterceptor extends Interceptor {
  final String header;
  final String language;

  RzLanguageInterceptor(this.language, {this.header = 'Accept-Language'});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[header] = language;
    handler.next(options);
  }
}


/ File: rz_logging_interceptor.dart **/

import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class RzLoggingInterceptor extends PrettyDioLogger {
  RzLoggingInterceptor()
      : super(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    compact: true,
  );
}

/ File: rz_network_interceptor.dart **/

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class RzNetworkInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final List<ConnectivityResult> connectivity =
    await Connectivity().checkConnectivity();

    if (connectivity.contains(ConnectivityResult.none)) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No Internet connection',
        ),
      );
      return;
    }

    handler.next(options);
  }
}

/ File: rz_response_transformer_interceptor.dart **/

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

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

  bool _isJsonString(dynamic data) {
    if (data is! String) return false;
    final trimmed = (data).trim();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }
}

/ File: rz_dio_provider.dart **/

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

import '../client/rz_dio_client_obj.dart';

class RzDioProvider {
  static RzDioProvider? _instance;
  late final dio.Dio _dio;
  String? _authToken;
  String _bearerPrefix = 'Bearer';

  /// Private constructor
  RzDioProvider._internal({
    String? authToken,
    VoidCallback? onUnauthorized,
    String? baseUrl,
  }) {
    _authToken = authToken;
    _dio = RzDioClient.buildClient(
      authToken: authToken,
      onUnauthorized: onUnauthorized,
      baseUrl: baseUrl,
    );
    // Set default responseType globally
    _dio.options.responseType = dio.ResponseType.json;
  }

  /// Factory constructor (Singleton)
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
  static void setContentType({String contentType = "application/json"}) {
    RzDioClient.setContentType(contentType: contentType);
  }

  /// Static method to set interceptors (call before instantiation)
  static void setInterceptors(dynamic interceptors) {
    RzDioClient.setInterceptors(interceptors);
  }

  /// Static method to set timeouts (proxies to RzDioClient)
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

  /// Set auth token dynamically
  RzDioProvider setAuth(String? token, {String bearerPrefix = 'Bearer'}) {
    _authToken = token;
    _bearerPrefix = bearerPrefix;
    RzDioClient.setAuth(token, bearerPrefix: bearerPrefix);
    return this;
  }

  RzDioProvider setToken(String? token, {String bearerPrefix = 'Bearer'}) {
    _authToken = token;
    _bearerPrefix = bearerPrefix;
    RzDioClient.setAuth(token, bearerPrefix: bearerPrefix);
    return this;
  }

  static dio.CancelToken createCancelToken() {
    return dio.CancelToken();
  }

  /// Optional: reset instance (useful on logout)
  static void reset() {
    _instance = null;
  }

  /* --------------------------------------------------------------------------
   * HTTP METHODS
   * -------------------------------------------------------------------------- */
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

/ File: rz_api_error.dart **/

class RzApiError {
  final int? statusCode;
  final String message;
  final dynamic raw;

  const RzApiError({
    this.statusCode,
    required this.message,
    this.raw,
  });

  factory RzApiError.unknown([dynamic raw]) {
    return RzApiError(
      message: 'Unknown error occurred',
      raw: raw,
    );
  }

  factory RzApiError.network([dynamic raw]) {
    return RzApiError(
      message: 'Network error. Please check your connection.',
      raw: raw,
    );
  }

  factory RzApiError.server({
    int? statusCode,
    String? message,
    dynamic raw,
  }) {
    return RzApiError(
      statusCode: statusCode,
      message: message ?? 'Server error occurred',
      raw: raw,
    );
  }
}

/ File: rz_api_failure.dart **/

import 'rz_api_error.dart';
import 'rz_api_response.dart';

class RzApiFailure<T> extends RzApiResponse<T> {
  final RzApiError error;

  const RzApiFailure(this.error);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(RzApiError error) failure,
  }) {
    return failure(error);
  }
}

/ File: rz_api_response.dart **/

import 'rz_api_error.dart';
import 'rz_api_success.dart';
import 'rz_api_failure.dart';

abstract class RzApiResponse<T> {
  const RzApiResponse();

  R when<R>({
    required R Function(T data) success,
    required R Function(RzApiError error) failure,
  });

  factory RzApiResponse.success(T data) = RzApiSuccess<T>;
  factory RzApiResponse.failure(RzApiError error) = RzApiFailure<T>;
}

/ File: rz_api_success.dart **/

import 'rz_api_error.dart';
import 'rz_api_response.dart';

class RzApiSuccess<T> extends RzApiResponse<T> {
  final T data;

  const RzApiSuccess(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(RzApiError error) failure,
  }) {
    return success(data);
  }
}

/ File: rz_dio_service.dart **/

import 'package:dio/dio.dart';
import '../response/rz_api_error.dart';
import '../response/rz_api_response.dart';

typedef DioCallWithToken = Future<Response> Function(CancelToken token);
typedef DioCallWithoutToken = Future<Response> Function();

class RzDioService {
  /* ----------------------------------------------------------------------
   * Generic API handler (SEALED ApiResponse)
   * ---------------------------------------------------------------------- */
  Future<RzApiResponse<T>> request<T>(
      dynamic call,                     // can be with or without token
      T Function(dynamic json) fromJson, {
        CancelToken? cancelToken,
      }) async {

    final token = cancelToken;

    try {
      Response response;

      if (call is DioCallWithToken) {
        response = await call(token ?? CancelToken());
      } else if (call is DioCallWithoutToken) {
        response = await call();
      } else {
        throw Exception("Invalid call type");
      }

      return RzApiResponse.success(fromJson(response.data));
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return RzApiResponse.failure(
          RzApiError(message: 'Request cancelled', raw: e),
        );
      }
      return RzApiResponse.failure(_mapDioError(e));
    } catch (e) {
      return RzApiResponse.failure(RzApiError.unknown(e));
    }
  }

  /* ----------------------------------------------------------------------
   * DioException → ApiError
   * ---------------------------------------------------------------------- */
  RzApiError _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return RzApiError.network("Connection timeout");

      case DioExceptionType.sendTimeout:
        return RzApiError.network("Send timeout");

      case DioExceptionType.receiveTimeout:
        return RzApiError.network("Receive timeout");

      case DioExceptionType.connectionError:
        return RzApiError.network("No internet connection");

      case DioExceptionType.cancel:
        return RzApiError(
          message: "Request cancelled",
          raw: e,
        );

      case DioExceptionType.badResponse:
        return RzApiError.server(
          statusCode: e.response?.statusCode,
          message: _extractServerMessage(e),
          raw: e.response?.data,
        );

      default:
        return RzApiError.unknown(e);
    }
  }

  String _extractServerMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
    }

    return "Server error (${e.response?.statusCode})";
  }
}

/ File: rz_dio_client.dart **/

export 'src/cancel/rz_cancel_token_manager.dart';
export 'src/interceptor/rz_auth_interceptor.dart';
export 'src/interceptor/rz_dio_printer_interceptor.dart';
export 'src/interceptor/rz_language_interceptor.dart';
export 'src/interceptor/rz_logging_interceptor.dart';
export 'src/interceptor/rz_network_interceptor.dart';
export 'src/interceptor/rz_response_transformer_interceptor.dart';
export 'src/response/rz_api_error.dart';
export 'src/response/rz_api_failure.dart';
export 'src/response/rz_api_response.dart';
export 'src/response/rz_api_success.dart';
export 'src/provider/rz_dio_provider.dart';
export 'src/services/rz_dio_service.dart';
export 'src/client/rz_dio_client_obj.dart';

