import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

/// A utility function to print debug information only in debug mode.
///
/// Uses [debugPrint] to output the string representation of [value] when
/// [kDebugMode] is true. This helps in logging without affecting release builds
/// and is used internally by [RzDioPrinterInterceptor] for structured output.
void printer(dynamic value) {
  if (kDebugMode) {
    debugPrint(value.toString());
  }
}

/// A custom Dio [Interceptor] for printing detailed logs of HTTP requests,
/// responses, and errors using [debugPrint] in debug mode only.
///
/// This interceptor provides verbose logging for development and debugging,
/// including method, URL, headers, query parameters, body for requests;
/// status code, headers, and data (JSON-encoded) for responses; and error
/// details (type, message, status code, response data) for failures. All logs
/// are prefixed with separators for easy identification in console output.
/// It does not alter the request/response flow and is intended for diagnostic
/// purposes only.
class RzDioPrinterInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    printer("= = = DIO REQUEST = = =");
    printer("METHOD : ${options.method}");
    printer("URL : ${options.baseUrl}${options.path}");
    printer("HEADERS : ${options.headers}");
    printer("CONTENT_TYPE : ${options.contentType}");
    printer("QUERY : ${options.queryParameters}");
    printer("EXTRA : ${options.extra}");
    printer("BODY : ${options.data}");
    printer("==========================");
    handler.next(options);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    printer("= = = DIO RESPONSE = = =");
    printer("URL : ${response.requestOptions.baseUrl}${response.requestOptions.path}");
    printer("STATUS CODE : ${response.statusCode}");
    printer("HEADERS : ${response.headers}");
    printer("EXTRA : ${response.extra}");
    printer("DATA : ${jsonEncode(response.data)}");
    printer("==========================");
    handler.next(response);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    printer("= = = DIO ERROR = = =");
    printer("URL : ${err.requestOptions.baseUrl}${err.requestOptions.path}");
    printer("TYPE : ${err.type}");
    printer("MESSAGE : ${err.message}");
    printer("STATUS CODE : ${err.response?.statusCode}");
    printer("RESPONSE : ${err.response?.data}");
    printer("==========================");
    handler.next(err);
  }
}