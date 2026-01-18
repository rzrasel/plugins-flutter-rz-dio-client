import 'package:dio/dio.dart';
import 'package:rz_dio_client/rz_dio_client.dart';
import 'model/rz_rasel_model.dart';

class RemoteDataProviderModel {
  final RzDioService _service = RzDioService();

  /* ------------------------------------------------------------
   * WITHOUT CancelToken, WITHOUT baseUrl
   * ------------------------------------------------------------ */
  Future<RzApiResponse<RzRaselModel>> fetchWithoutCancelBaseUrl() {
    final dio = RzDioProvider();

    return _service.request<RzRaselModel>(
          () => dio.get(
        'https://httpbin.org/get',
        options: Options(responseType: ResponseType.json),
      ),
          (json) => RzRaselModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /* ------------------------------------------------------------
   * WITH CancelToken, WITHOUT baseUrl
   * ------------------------------------------------------------ */
  Future<RzApiResponse<RzRaselModel>> fetchWithCancelWithoutBaseUrl(
      CancelToken token,
      ) {
    final dio = RzDioProvider();

    return _service.request<RzRaselModel>(
          (t) => dio.get(
        'https://httpbin.org/delay/5',
        cancelToken: t,
        options: Options(responseType: ResponseType.json),
      ),
          (json) => RzRaselModel.fromJson(json as Map<String, dynamic>),
      cancelToken: token,
    );
  }

  /* ------------------------------------------------------------
   * WITHOUT CancelToken, WITH baseUrl
   * ------------------------------------------------------------ */
  Future<RzApiResponse<RzRaselModel>> fetchWithoutCancelWithBaseUrl() {
    final dio = RzDioProvider(baseUrl: 'https://httpbin.org');

    return _service.request<RzRaselModel>(
          () => dio.get(
        '/get',
        options: Options(responseType: ResponseType.json),
      ),
          (json) => RzRaselModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /* ------------------------------------------------------------
   * WITH CancelToken, WITH baseUrl
   * ------------------------------------------------------------ */
  Future<RzApiResponse<RzRaselModel>> fetchWithCancelWithBaseUrl(
      CancelToken token,
      ) {
    final dio = RzDioProvider(baseUrl: 'https://httpbin.org');

    return _service.request<RzRaselModel>(
          (t) => dio.get(
        '/delay/5',
        cancelToken: t,
        options: Options(responseType: ResponseType.json),
      ),
          (json) => RzRaselModel.fromJson(json as Map<String, dynamic>),
      cancelToken: token,
    );
  }
}