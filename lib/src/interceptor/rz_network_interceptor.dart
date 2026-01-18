import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// A Dio [Interceptor] that checks for network connectivity before sending
/// requests using the [connectivity_plus] package.
///
/// If no internet connection is detected, it rejects the request with a
/// [DioExceptionType.connectionError], preventing unnecessary network calls
/// and providing early feedback on connectivity issues. This interceptor
/// operates on the request phase and does not modify successful requests.
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