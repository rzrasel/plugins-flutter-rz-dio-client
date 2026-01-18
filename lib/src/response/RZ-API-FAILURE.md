# RzApiFailure

`RzApiFailure` is a concrete subclass of the sealed `RzApiResponse` hierarchy. It represents the **failure** state of an API request, holding a detailed `RzApiError` object that describes what went wrong (e.g., network issues, server errors, unknown exceptions). This class enables type‑safe and exhaustive error handling in your API layer.

## Short Description

`RzApiFailure<T>` is the counterpart to `RzApiSuccess<T>` in the `RzApiResponse` sealed union. It is returned by API service methods when an error occurs, carrying an `RzApiError` with status code, human‑readable message, and raw error data. By using the `when` method or Dart’s pattern matching (Dart 3+), you can handle success and failure cases explicitly and without missing any branch.

## Features

- **Type‑Safe Failure Representation:** Part of a sealed class hierarchy, forcing exhaustive handling of both success and failure.
- **Detailed Error Information:** Holds an `RzApiError` object with HTTP status code, message, and raw data.
- **Functional Pattern Matching:** Provides the `when` method to handle responses using callback functions.
- **Immutable:** All properties are final, ensuring predictable state.
- **Factory Constructors:** The base `RzApiResponse` offers `success()` and `failure()` factory constructors for convenient creation.
- **Framework‑agnostic:** Works in any Dart or Flutter project.

## Basic Use

Creating a failure response is straightforward. You first build an `RzApiError` and then instantiate `RzApiFailure` with it.

```dart
import 'rz_api_error.dart';
import 'rz_api_response.dart';

// Build an error
final error = RzApiError.server(
  statusCode: 500,
  message: 'Internal Server Error',
  raw: '{"error": "Something went wrong"}',
);

// Create a failure response
final response = RzApiFailure<String>(error);

// Use the when method to handle it
final message = response.when(
  success: (data) => 'Success: $data',
  failure: (err) => 'Failed: ${err.message} (${err.statusCode})',
);
print(message); // Failed: Internal Server Error (500)
```

### All Properties

RzApiFailure<T>

| Property | Type | Type Details | Description |
|---|---|---|---|
| `error` | `RzApiError` | `final` | Error details associated with this failure response. Contains `statusCode`, `message`, and `raw` data. |

Inherited from RzApiResponse<T>

| Method | Signature | Description |
|---|---|---|
| `when` | `R when<R>({required R Function(T data) success, required R Function(RzApiError error) failure})` | Performs exhaustive pattern matching. Invokes `failure(error)` for this class. |

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

Compatible with dio, http, flutter_bloc, riverpod, getx, and any state management.

# Author

Rz Rasel