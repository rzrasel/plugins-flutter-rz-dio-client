/ File: remote_data_provider.dart **/

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


/ File: main.dart **/

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rz_dio_client_example/src/remote_data_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RemoteDataProvider _provider = RemoteDataProvider();

  CancelToken cancelToken = CancelToken();

  String _result = "";
  String _error = "";
  bool _loading = false;

  void _callWithoutCancelBaseUrl() async {
    setState(() {
      _loading = true;
      _result = "";
      _error = "";
    });

    final response = await _provider.fetchWithoutCancelBaseUrl();

    response.when(
      success: (data) {
        setState(() {
          _result = data;
        });
      },
      failure: (err) {
        setState(() {
          _error = err.message;
        });
      },
    );

    setState(() => _loading = false);
  }

  void _callWithCancelBaseUrl() async {
    cancelToken = CancelToken(); // reset token

    setState(() {
      _loading = true;
      _result = "";
      _error = "";
    });

    final response =
    await _provider.fetchWithCancelWithoutBaseUrl(cancelToken);

    response.when(
      success: (data) {
        setState(() {
          _result = data;
        });
      },
      failure: (err) {
        setState(() {
          _error = err.message;
        });
      },
    );

    setState(() => _loading = false);
  }

  void _cancel() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel("User cancelled");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rz Dio Client Demo")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _callWithoutCancelBaseUrl,
              child: const Text("Fetch Without Cancel + No BaseUrl"),
            ),
            ElevatedButton(
              onPressed: _loading ? null : _callWithCancelBaseUrl,
              child: const Text("Fetch With Cancel + No BaseUrl"),
            ),
            ElevatedButton(
              onPressed: _cancel,
              child: const Text("Cancel Request"),
            ),
            const SizedBox(height: 20),

            if (_loading) const CircularProgressIndicator(),

            if (_result.isNotEmpty)
              Text("Result:\n$_result"),

            if (_error.isNotEmpty)
              Text("Error:\n$_error", style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
