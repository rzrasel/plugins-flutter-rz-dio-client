# Flutter Rz Dio Client

[![RzRasel Flutter](https://img.shields.io/badge/RzRasel-Flutter-blue.svg)](https://github.com/rzrasel/flutter-plugins-rz-dio-client)
[![Dio Client](https://img.shields.io/badge/Dio-Networking-brightgreen)](https://github.com/rzrasel/flutter-plugins-rz-dio-client)
[![pub package](https://img.shields.io/pub/v/rz_dio_client.svg)](https://pub.dev/packages/rz_dio_client)
![GitHub License](https://img.shields.io/github/license/rzrasel/flutter-plugins-rz-dio-client)
[![GitHub stars](https://img.shields.io/github/stars/rzrasel/flutter-plugins-rz-dio-client)](https://github.com/rzrasel/flutter-plugins-rz-dio-client)

---

## rz_dio_client

**Rz Dio Client** is a **production-ready Dio abstraction for Flutter** built for  
**Clean Architecture**, **MVVM**, and **large-scale applications**.

It provides:
- A **sealed API response layer**
- **CancelToken lifecycle management**
- **Interceptor-first design**
- **Web-safe & mobile-safe configuration**
- **Dependency Injection friendly**

---

# 🚀 CURRENT VERSION (Recommended)

> This is the **latest architecture**, optimized for **scalability, DI, and Clean Architecture**.

---

## ✨ Features

- ✅ Dio Singleton Provider
- ✅ Sealed API Response (`Success / Failure`)
- ✅ Managed CancelToken lifecycle
- ✅ Global & per-request authentication
- ✅ Web-safe timeout handling
- ✅ Automatic JSON transformation
- ✅ Network connectivity guard
- ✅ Pretty logging & printer interceptor
- ✅ Modular interceptor system
- ✅ Clean Architecture friendly

---

## 📦 Installation

```yaml
dependencies:
  rz_dio_client: ^latest_version
  dio: ^latest_version
  pretty_dio_logger: ^latest_version
  connectivity_plus: ^latest_version
```

---

## 📥 Import

```dart
import 'package:rz_dio_client/rz_dio_client.dart';
```

---

## 🔌 Dependency Injection (GetX Example)

```dart
Get.lazyPut(() => DioProvider(baseUrl: ApiConstant.baseUrl));
Get.lazyPut(() => DioService());

Get.lazyPut<HomeRemoteDao>(() => HomeRemoteDao(Get.find(), Get.find()));
Get.lazyPut<HomeRepository>(() => HomeRepositoryImpl(Get.find()));
Get.lazyPut(() => HomeController(Get.find()));
```

---

## 🔧 Dependency Injection with Interceptors

```dart
DioClient.setInterceptors([
  RzNetworkInterceptor(),
  RzAuthInterceptor(authToken: null),
  RzLanguageInterceptor('en'),
  RzResponseTransformerInterceptor(),
  if (Get.isLogEnable) RzLoggingInterceptor(),
  if (kDebugMode) RzDioPrinterInterceptor(),
]);

Get.lazyPut(() => DioProvider());
Get.lazyPut(() => DioService());

Get.lazyPut(() => PostItemRemoteDao(Get.find(), Get.find()));
Get.lazyPut<PostItemRepository>(() => PostItemRepositoryImpl(Get.find()));
Get.lazyPut(() => PostItemController(Get.find()));
```

---

## 🧩 DAO Example (Model-based)

```dart
class HomeRemoteDao {
  final DioService _dioService;
  final DioProvider _dioProvider;

  HomeRemoteDao(this._dioService, this._dioProvider);

  Future<ApiResponse<HomeModel>> fetchHomeData(CancelToken? cancelToken) {
    return _dioService.request<HomeModel>(
      (token) => _dioProvider.get(
        ApiConstant.homeUrl,
        cancelToken: token,
        options: Options(responseType: ResponseType.json),
      ),
      (json) => HomeModel.fromJson(json),
      cancelToken: cancelToken,
    );
  }
}
```

---

## 🧠 Dynamic Auth (Per Request)

```dart
class RemoteDataProviderModelWithOption {
  final RzDioService _service = RzDioService();

  Future<RzApiResponse<RzRaselModel>> fetchModel({
    required String url,
    String? authToken,
    String? baseUrl,
    CancelToken? cancelToken,
  }) {
    final dio = RzDioProvider(baseUrl: baseUrl);

    final headers = <String, dynamic>{};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return _service.request<RzRaselModel>(
      () => dio.get(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.json,
          headers: headers,
        ),
      ),
      (json) => RzRaselModel.fromJson(json),
    );
  }
}
```

---

# 🧱 OLD / LEGACY VERSION (Still Supported)

> This section contains the **previous raw-style usage**.  
> Useful for **quick calls, demos, and migration reference**.

---

## 🔹 Raw String Usage

```dart
class RemoteDataProvider {
  final RzDioService _service = RzDioService();

  Future<RzApiResponse<String>> fetchWithoutCancelBaseUrl() {
    final dio = RzDioProvider();

    return _service.request<String>(
      () => dio.get(
        'https://rzrasel.org/get',
        options: Options(responseType: ResponseType.plain),
      ),
      (json) => json.toString(),
    );
  }
}
```

---

## 🔹 With CancelToken

```dart
Future<RzApiResponse<String>> fetchWithCancel(
  CancelToken token,
) {
  final dio = RzDioProvider(baseUrl: 'https://rzrasel.org');

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
```

---

## 🔹 Call Example

```dart
CancelToken cancelToken = CancelToken();

final response = await provider.fetchWithCancel(cancelToken);

response.when(
  success: (data) => print(data),
  failure: (error) => print(error.message),
);

cancelToken.cancel("User cancelled");
```

---

## 🔹 Legacy Model Usage

```dart
Future<RzApiResponse<RzRaselModel>> fetchModel() {
  final dio = RzDioProvider();

  return _service.request<RzRaselModel>(
    () => dio.get(
      'https://rzrasel.org/get',
      options: Options(responseType: ResponseType.json),
    ),
    (json) => RzRaselModel.fromJson(json),
  );
}
```

---

## ✅ Recommendation

- ✅ **Use CURRENT VERSION for new projects**
- 🧱 **Legacy version kept for backward compatibility**
- 🔄 Migration is straightforward

---

**Maintained by:**  
**Rz Rasel**  
Flutter • Clean Architecture • Networking

---

## rz_dio_client

**Rz Dio Client** is a **production-ready Dio abstraction for Flutter** built for  
**Clean Architecture**, **MVVM**, and **large-scale applications**.

It provides:
- A **sealed API response layer**
- **CancelToken lifecycle management**
- **Interceptor-first design**
- **Web-safe & mobile-safe configuration**
- **Dependency Injection friendly**

---

## ✨ Features

- ✅ Dio Singleton Provider
- ✅ Sealed API Response (`Success / Failure`)
- ✅ Managed CancelToken lifecycle
- ✅ Global & per-request authentication
- ✅ Web-safe timeout handling
- ✅ Automatic JSON transformation
- ✅ Network connectivity guard
- ✅ Pretty logging & printer interceptor
- ✅ Modular interceptor system
- ✅ Clean Architecture friendly

---

## 📦 Installation

## Usage

### 1. Add library to your pubspec.yaml

latest version: [![pub package](https://img.shields.io/pub/v/rz_dio_client.svg)](https://pub.dartlang.org/packages/rz_dio_client)

```yaml
dependencies:
  responsive_builder_kit: ^latest_version
```

```dio
dio: ^latest_version
pretty_dio_logger: ^latest_version
connectivity_plus: ^latest_version
```

### 2. Import library in dart file

```dart
import 'package:rz_dio_client/rz_dio_client.dart';
```

## Usages - Dependency Injection:

```
Get.lazyPut(() => DioProvider(baseUrl: ApiConstant.baseUrl));
Get.lazyPut(() => DioService());

Get.lazyPut<HomeRemoteDao>(() => HomeRemoteDao(Get.find(), Get.find()),);
Get.lazyPut<HomeRepository>(() => HomeRepositoryImpl(Get.find()),);
Get.lazyPut(() => HomeController(Get.find()),);
```

## Usages - Dependency Injection With Options:

```
// 1️⃣ Set interceptors BEFORE DioProvider is created
DioClient.setInterceptors([
  RzNetworkInterceptor(),
  RzAuthInterceptor(authToken: null),
  RzLanguageInterceptor('en'),
  RzResponseTransformerInterceptor(),
  if (Get.isLogEnable) RzLoggingInterceptor(),
  if (kDebugMode) RzDioPrinterInterceptor(),
]);
// 2️⃣ Create DioProvider singleton
//Get.lazyPut(() => DioProvider(baseUrl: "https://yourapi.com"));
Get.lazyPut(() => DioProvider());
// 3️⃣ DioService depends on DioProvider
Get.lazyPut(() => DioService());
// PostItem dependencies
Get.lazyPut(() => PostItemRemoteDao(Get.find(), Get.find()));
Get.lazyPut<PostItemRepository>(() => PostItemRepositoryImpl(Get.find()));
Get.lazyPut(() => PostItemController(Get.find()));
```

```HomeRemoteDao
class HomeRemoteDao {
  final DioService _dioService;
  final DioProvider _dioProvider;

  HomeRemoteDao(this._dioService, this._dioProvider);

  Future<ApiResponse<HomeModel>> fetchHomeData(
      CancelToken? cancelToken,
      ) {
    return _dioService.request<HomeModel>(
          (token) => _dioProvider.get(
        ApiConstant.homeUrl,
        options: Options(responseType: ResponseType.json),
        cancelToken: token,
      ),
          (json) => HomeModel.fromJson(json),
      cancelToken: cancelToken,
    );
  }
}
```

```PostItemRemoteDao
class PostItemRemoteDao {
  final DioService _dioService;
  final DioProvider _dioProvider;

  PostItemRemoteDao(this._dioService, this._dioProvider);

  /// Fetch single post by slug or id
  Future<ApiResponse<PostItemEntity>> fetchPostBySlug(PostItemRequestModel request) {
    return _dioService.request<PostItemEntity>(
          () => _dioProvider.post(
        ApiConstant.postItemBySlugUrl,
        data: request.toJson(),
        options: Options(responseType: ResponseType.json),
      ),
          (json) => PostItemEntity.fromJson(json),
    );
  }
}
```

## Usages - Raw String:

```
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
        'https://rzrasel.org/get',
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
        'https://rzrasel.org/delay/5',
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
    final dio = RzDioProvider(baseUrl: 'https://rzrasel.org');

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
    final dio = RzDioProvider(baseUrl: 'https://rzrasel.org');

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
```

** Call RemoteDataProvider:

```
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
```

## Usages - Model:

```
class RemoteDataProviderModel {
  final RzDioService _service = RzDioService();

  /* ------------------------------------------------------------
   * WITHOUT CancelToken, WITHOUT baseUrl
   * ------------------------------------------------------------ */
  Future<RzApiResponse<RzRaselModel>> fetchWithoutCancelBaseUrl() {
    final dio = RzDioProvider();

    return _service.request<RzRaselModel>(
          () => dio.get(
        'https://rzrasel.org/get',
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
        'https://rzrasel.org/delay/5',
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
    final dio = RzDioProvider(baseUrl: 'https://rzrasel.org');

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
    final dio = RzDioProvider(baseUrl: 'https://rzrasel.org');

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
```

## Usages - Model With Option:

```
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
```

** Usage Example

```
final provider = RemoteDataProviderModelWithOption();
final response = await provider.fetchModel(
  url: '/api/user',
  authToken: 'your-dynamic-token-here', // Can change per call
  baseUrl: 'https://api.example.com',
  cancelToken: CancelToken(),
);
response.when(
  success: (model) => print(model.name), // Assuming RzRaselModel has 'name'
  failure: (error) => print(error.message),
);
```

** Alternative: Stick to Interceptor with Singleton Reset

```
class RemoteDataProviderModelWithOption {
  final RzDioService _service = RzDioService();

  Future<RzApiResponse<RzRaselModel>> fetchModel({
    required String url,
    String? authToken,
    String? baseUrl,
    CancelToken? cancelToken,
  }) {
    // Reset singleton to allow new authToken/baseUrl
    RzDioProvider.reset();

    final dio = RzDioProvider(
      authToken: authToken,
      baseUrl: baseUrl,
    );
    return _service.request<RzRaselModel>(
      () => dio.get<RzRaselModel>(
        url,
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.json),
      ),
      (json) => RzRaselModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
```

### Why this structure?

```
rz_dio_client.dart
        │
        ▼
   RzDioProvider
        │
        ▼
    RzDioClient
        │
        ▼
       Dio
        │
        ├── RzAuthInterceptor
        ├── RzNetworkInterceptor
        ├── RzResponseTransformerInterceptor
        ├── RzLoggingInterceptor
        └── RzDioPrinterInterceptor


RzDioProvider
        │
        ▼
   RzDioService
        │
        ▼
 RzApiResponse<T>
       / \
      /   \
     ▼     ▼
 Success  Failure
            │
            ▼
       RzApiError
```

### Dependency flow

The important part is to keep the dependency direction clear:

                 ┌────────────────────┐
                 │  Application/User  │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │   RzDioProvider    │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │    RzDioService    │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │     RzDioClient    │
                 └─────────┬──────────┘
                           │
                           ▼
                       ┌───────┐
                       │ Dio   │
                       └───┬───┘
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
          Auth         Network        Logging
       Interceptor   Interceptor    Interceptor

#### And response handling:

```
Dio
 │
 ▼
HTTP Response
 │
 ▼
RzDioService
 │
 ├── success ──────► RzApiSuccess<T>
 │
 └── exception ────► RzApiFailure<T>
                           │
                           ▼
                      RzApiError
```

## 📤 Publish to pub.dev

```bash
flutter pub publish --dry-run
flutter pub publish
```