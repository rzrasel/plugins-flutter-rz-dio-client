import 'package:dio/dio.dart';
import '../response/rz_api_error.dart';
import '../response/rz_api_response.dart';

typedef DioCallWithToken = Future<Response> Function(CancelToken token);
typedef DioCallWithoutToken = Future<Response> Function();

/// A service class for handling API requests using Dio, providing a generic
/// wrapper for success and error responses.
class RzDioService {
  /* ----------------------------------------------------------------------
   * Generic API handler (SEALED ApiResponse)
   * ---------------------------------------------------------------------- */
  /// Performs an API request using the provided [call] function, which can
  /// either require a [CancelToken] (with token) or not (without token).
  ///
  /// - [call]: The Dio call function, either [DioCallWithToken] or [DioCallWithoutToken].
  /// - [fromJson]: A function to deserialize the JSON response data into type [T].
  /// - [cancelToken]: Optional [CancelToken] for cancelling the request.
  ///
  /// Returns a [Future] that resolves to [RzApiResponse<T>] containing either
  /// success data or a failure with an [RzApiError].
  ///
  /// Throws an [Exception] if the [call] is of an invalid type.
  Future<RzApiResponse<T>> request<T>(
      dynamic call, // can be with or without token
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