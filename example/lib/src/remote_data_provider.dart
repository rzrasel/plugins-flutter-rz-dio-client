import 'package:dio/dio.dart';
import 'package:rz_dio_client/rz_dio_client.dart';

//RemoteDataProvider (RAW STRING)
class RemoteDataProvider {
  final RzDioService _service = RzDioService();

  /* ------------------------------------------------------------
   * WITHOUT CancelToken, WITHOUT baseUrl
   * ------------------------------------------------------------ */
  Future<RzApiResponse<String>> fetchWithoutCancelBaseUrl() {
    final dio = RzDioProvider();

    return _service.request<String>(
          () => dio.get(
        'https://httpbin.org/get',
        options: Options(responseType: ResponseType.plain),
      ),
          (json) => json.toString(),
    );
  }

  /* ------------------------------------------------------------
   * WITH CancelToken, WITHOUT baseUrl
   * ------------------------------------------------------------ */
  Future<RzApiResponse<String>> fetchWithCancelWithoutBaseUrl(
      CancelToken token,
      ) {
    final dio = RzDioProvider();

    return _service.request<String>(
          (t) => dio.get(
        'https://httpbin.org/delay/5',
        cancelToken: t,
        options: Options(responseType: ResponseType.plain),
      ),
          (json) => json.toString(),
      cancelToken: token,
    );
  }

  /* ------------------------------------------------------------
   * WITHOUT CancelToken, WITH baseUrl
   * ------------------------------------------------------------ */
  Future<RzApiResponse<String>> fetchWithoutCancelWithBaseUrl() {
    final dio = RzDioProvider(baseUrl: 'https://httpbin.org');

    return _service.request<String>(
          () => dio.get(
        '/get',
        options: Options(responseType: ResponseType.plain),
      ),
          (json) => json.toString(),
    );
  }

  /* ------------------------------------------------------------
   * WITH CancelToken, WITH baseUrl
   * ------------------------------------------------------------ */
  Future<RzApiResponse<String>> fetchWithCancelWithBaseUrl(
      CancelToken token,
      ) {
    final dio = RzDioProvider(baseUrl: 'https://httpbin.org');

    return _service.request<String>(
          (t) => dio.get(
        '/delay/5',
        cancelToken: t,
        options: Options(responseType: ResponseType.plain),
      ),
          (json) => json.toString(),
      cancelToken: token,
    );
  }
}
