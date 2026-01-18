# RzApiResponse

`RzApiResponse` is a sealed (or abstract) base class that models the outcome of an API request as either a **success** (with data) or a **failure** (with an error). It provides a uniform, type‑safe way to handle API responses and enforces exhaustive handling through its `when` method.

## Short Description

`RzApiResponse<T>` is the root of a sealed union that represents the result of an API call. It has two concrete subclasses: `RzApiSuccess<T>` (holding deserialised data) and `RzApiFailure<T>` (holding an `RzApiError`). By using the `when` method – or Dart’s pattern matching (Dart 3+) – you can safely and completely handle both outcomes without missing any branch. This pattern eliminates the need for manual type checks or nullable error fields.

## Features

- **Sealed Union Pattern:** Represents two disjoint states – success and failure – in a type‑safe manner.
- **Exhaustive Handling:** The `when` method forces callers to provide callbacks for both success and failure, ensuring no case is overlooked.
- **Factory Constructors:** Convenient `RzApiResponse.success()` and `RzApiResponse.failure()` factories to create instances without importing concrete subclasses.
- **Immutable:** All implementing classes are immutable, making responses predictable and safe to pass around.
- **Generic:** Works with any data type `T` for the successful payload.
- **Framework‑agnostic:** Works in any Dart or Flutter project.

## Basic Use

You never instantiate `RzApiResponse` directly; instead, you use its factory constructors or create instances of its subclasses.

```dart
import 'rz_api_error.dart';
import 'rz_api_response.dart';

// Create a success response
final successResponse = RzApiResponse.success<String>('Hello');

// Create a failure response
final error = RzApiError.server(statusCode: 404, message: 'Not found');
final failureResponse = RzApiResponse.failure<int>(error);

// Handle the response using the when method
final message = successResponse.when(
  success: (data) => 'Success: $data',
  failure: (err) => 'Error: ${err.message}',
);
print(message); // Success: Hello
```

### Basic APT Use

```dart
import 'package:rz_dio_client/rz_dio_client.dart';

final RzDioService _dioService;
final RzDioProvider _dioProvider;

// 1. Return RzApiResponse from RemoteDao
Future<RzApiResponse<UserDto>> getUser(int id) {
  return _dioService.request<UserDto>(
    (token) => _dioProvider.get(
      '/users/$id',
      cancelToken: token,
    ),
    (json) => UserDto.fromJson(json),
  );
}

// 2. Handle in UI / Cubit
final response = await getUser(1);

response.when(
  success: (userDto) => print(userDto.name),
  failure: (error) => print('[${error.statusCode}] ${error.message}'),
);
```

### Full Feature Use

In a real API service, you would return an RzApiResponse from a method that performs an HTTP request. The response is then processed in the UI layer.

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<RzApiResponse<Map<String, dynamic>>> getUser(int id) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.example.com/users/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RzApiResponse.success(data);
      } else {
        final error = RzApiError.server(
          statusCode: response.statusCode,
          message: 'Request failed with status ${response.statusCode}',
          raw: response.body,
        );
        return RzApiResponse.failure(error);
      }
    } on http.ClientException catch (e) {
      return RzApiResponse.failure(RzApiError.network(e));
    } catch (e) {
      return RzApiResponse.failure(RzApiError.unknown(e));
    }
  }
}

// Usage in a widget or controller
void loadUser() async {
  final response = await ApiService().getUser(42);
  response.when(
    success: (user) {
      // Update UI with user data
      print('User: ${user['name']}');
    },
    failure: (error) {
      // Show error to user
      print('Error: ${error.message}');
    },
  );
}
```

### Advanced API Use

```dart
import 'package:dio/dio.dart';
import 'package:rz_dio_client/rz_dio_client.dart';

class CreateBatchLanguageRemoteDao {
  CreateBatchLanguageRemoteDao(this._dioService, this._dioProvider);

  final RzDioService _dioService;
  final RzDioProvider _dioProvider;

  Future<RzApiResponse<CreateBatchLanguageResponseEntity>> createBatchLanguage({
    required CreateBatchLanguageRequestEntity requestEntity,
    CancelToken? cancelToken,
  }) {
    return _dioService.request<CreateBatchLanguageResponseEntity>(
      (token) => _dioProvider.post(
        ApiConstant.createBatchLanguageUrl,
        data: requestEntity.toJson(),
        options: Options(responseType: ResponseType.json),
        cancelToken: token,
      ),
      (json) => CreateBatchLanguageResponseEntity.fromJson(json),
      cancelToken: cancelToken,
    );
  }
}

// In Repository - use map() for Entity -> Model
class CreateBatchLanguageRepository {
  CreateBatchLanguageRepository(this._remoteDao);
  final CreateBatchLanguageRemoteDao _remoteDao;

  Future<RzApiResponse<CreateBatchLanguageModel>> create({
    required CreateBatchLanguageRequestEntity request,
    CancelToken? cancelToken,
  }) async {
    final res = await _remoteDao.createBatchLanguage(
      requestEntity: request,
      cancelToken: cancelToken,
    );
    return res.map((entity) => entity.toModel());
  }
}

// In Cubit
Future<void> createBatch(List<String> langs) async {
  emit(Loading());
  final response = await _repository.create(
    request: CreateBatchLanguageRequestEntity(languages: langs),
  );
  emit(response.when(
    success: (model) => Success(model.batchId),
    failure: (err) => Error(err.message),
  ));
}
```

### All Properties & Methods

RzApiResponse<T> (Abstract)

| Member | Type | Description |
|---|---|---|
| `const RzApiResponse()` | Constructor | Abstract `const` constructor for subclasses |
| `when<R>()` | `R when<R>({required R Function(T data) success, required R Function(RzApiError error) failure})` | Core method that performs exhaustive pattern matching. Both `success` and `failure` callbacks are required. Returns `R` |
| `RzApiResponse.success(T data)` | Factory | Creates an `RzApiSuccess<T>` instance containing the response data |
| `RzApiResponse.failure(RzApiError error)` | Factory | Creates an `RzApiFailure<T>` instance containing the error |

Subclasses

| Class | Property | Type | Description |
|---|---|---|---|
| `RzApiSuccess<T>` | `data` | `T` | The deserialized success data |
| `RzApiFailure<T>` | `error` | `RzApiError` | Error details containing `statusCode`, `message`, and `raw` data |

### Supported Platforms

Pure Dart - no native code, no platform dependencies.

| Platform | Supported | Notes |
| :--- | :---: | :--- |
| **Android** | ✅ | Fully supported |
| **iOS** | ✅ | Fully supported |
| **Web** | ✅ | Fully supported, web-safe error mapping |
| **Windows** | ✅ | Fully supported |
| **macOS** | ✅ | Fully supported |
| **Linux** | ✅ | Fully supported |
- All platforms where Dart/Flutter runs

Compatible with: dio, http, chopper, graphql, flutter_bloc, riverpod, getx, provider.

# Author

Rz Rasel