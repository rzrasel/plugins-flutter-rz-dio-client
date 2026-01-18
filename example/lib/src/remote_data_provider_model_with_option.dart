import 'package:dio/dio.dart';
import 'package:rz_dio_client/rz_dio_client.dart';
import 'model/rz_rasel_model.dart';

class RemoteDataProviderModelWithOption {
  final RzDioService _service = RzDioService();

  Future<RzApiResponse<RzRaselModel>> fetchModel({
    required String url,
    String? authToken,
    String? baseUrl,
    CancelToken? cancelToken,
  }) {
    // Create Dio instance (singleton handles baseUrl fine)
    final dio = RzDioProvider(baseUrl: baseUrl);

    // Build headers dynamically (per-request auth)
    final Map<String, dynamic> headers = {};
    if (authToken != null && authToken.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${authToken.trim()}';
    }

    return _service.request<RzRaselModel>(
          () => dio.get<RzRaselModel>(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.json,
          headers: headers, // Inject auth here
        ),
      ),
          (json) => RzRaselModel.fromJson(json as Map<String, dynamic>),
    );
  }
}