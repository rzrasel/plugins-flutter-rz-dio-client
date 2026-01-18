# RzApiSuccess

`RzApiSuccess` is a concrete subclass of the sealed `RzApiResponse` hierarchy that represents a **successful** API response. It holds the deserialised data of type `T` and enables type‑safe, exhaustive handling of API results alongside its counterpart `RzApiFailure`.

## Short Description

`RzApiSuccess<T>` is the success branch of the `RzApiResponse` sealed union. Returned by API service methods when a request completes successfully, it carries the parsed response data. Together with `RzApiFailure`, it provides a uniform way to model API outcomes, ensuring that both success and error paths are handled explicitly through pattern matching or the `when` method.

## Features

- **Type‑Safe Success Representation:** Part of a sealed class hierarchy, guaranteeing exhaustive handling of successful responses.
- **Holds Deserialised Data:** Stores the parsed data of generic type `T`.
- **Functional Pattern Matching:** Offers the `when` method to process the response with callback functions.
- **Immutable:** All properties are final, promoting predictable state management.
- **Factory Constructors:** The base `RzApiResponse` provides `success()` factory for convenient creation.
- **Framework‑agnostic:** Works seamlessly in any Dart or Flutter project.

## Basic Use

Create a success response by instantiating `RzApiSuccess` with your data.

```dart
import 'rz_api_error.dart';
import 'rz_api_response.dart';

// A successful response with a string
final response = RzApiSuccess<String>('Hello, World!');

// Use the when method to extract the data
final result = response.when(
  success: (data) => 'Data received: $data',
  failure: (error) => 'Error: ${error.message}',
);
print(result); // Data received: Hello, World!
```
### All Properties

RzApiSuccess<T>

| Property | Type | Modifier | Description |
|---|---|---|---|
| `data` | `T` | `final` | The deserialized data from the successful API response. Can be any type, including a single object, list, primitive, or `void`. |

Inherited from RzApiResponse<T>

| Method | Signature | Description |
|---|---|---|
| `when` | `R when<R>({required R Function(T data) success, required R Function(RzApiError error) failure})` | Performs exhaustive pattern matching. For `RzApiSuccess`, invokes `success(data)` and returns its result. |

### Supported Platforms

This is a pure Dart class with zero platform dependencies. Fully supported on:
| Platform | Supported | Notes |
| :--- | :---: | :--- |
| **Android** | ✅ | Fully supported |
| **iOS** | ✅ | Fully supported |
| **Web** | ✅ | Fully supported, web-safe error mapping |
| **Windows** | ✅ | Fully supported |
| **macOS** | ✅ | Fully supported |
| **Linux** | ✅ | Fully supported |
- Any platform where Dart/Flutter runs

Works perfectly with dio, http, flutter_bloc, riverpod, getx.

# Author

Rz Rasel