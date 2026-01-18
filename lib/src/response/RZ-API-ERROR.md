# RzApiError

`RzApiError` is a Dart class that encapsulates error details from API failures, providing a consistent and informative structure for error handling across your application.

## Short Description

`RzApiError` standardises the way you represent API errors. It holds an optional HTTP status code, a mandatory human‑readable message, and raw error data (such as the original exception or response body). The class includes factory constructors for common error types—unknown, network, and server—making it easy to create meaningful error objects in any API client.

## Features

- **Structured Error Model:** Captures `statusCode`, `message`, and `raw` data in one object.
- **Optional Status Code:** Supports HTTP status codes for server responses.
- **Raw Data Storage:** Keeps the original exception or response payload for debugging.
- **Factory Constructors:** Quick creation for:
    - `unknown()` – generic or unexpected errors.
    - `network()` – connectivity issues.
    - `server()` – server‑side errors with custom message and status code.
- **Immutable:** All fields are final, ensuring thread‑safe and predictable state.
- **Lightweight:** Zero dependencies; works in any Dart or Flutter project.

## Basic Use

Create an instance using the default constructor or one of the factory constructors.

```dart
// Default constructor
final error = RzApiError(
  statusCode: 404,
  message: 'User not found',
  raw: {'error': 'Not Found'},
);

// Network error factory
final networkError = RzApiError.network();

// Unknown error factory
final unknownError = RzApiError.unknown('Unexpected exception');

print(networkError.message); // Network error. Please check your connection.
```

### Full Feature Use

In a typical API service, you’ll catch exceptions and convert them to `RzApiError` instances.

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchUserProfile() async {
  try {
    final response = await http.get(
      Uri.parse('https://api.example.com/profile'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Process data...
    } else {
      // Server error with status code
      throw RzApiError.server(
        statusCode: response.statusCode,
        message: 'Failed to load profile',
        raw: response.body,
      );
    }
  } on http.ClientException catch (e) {
    // Network error
    throw RzApiError.network(e);
  } catch (e) {
    // Unexpected error
    throw RzApiError.unknown(e);
  }
}

void handleError(RzApiError error) {
  print('Error [${error.statusCode}]: ${error.message}');
  // Log raw data for diagnostics
  print('Raw: ${error.raw}');
}
```

### All Properties

| Property | Type | Required | Description |
|---|---|---|---|
| `statusCode` | `int?` | No | HTTP status code, e.g. `400`, `401`, `404`, `500`. `null` for network or unknown errors |
| `message` | `String` | Yes | Human-readable error message for UI display |
| `raw` | `dynamic` | No | Raw error data, such as the original exception, `DioException`, or response body for debugging |

Factory Constructors:

| Factory | Signature | Default Message | Use Case |
|---|---|---|---|
| `unknown` | `RzApiError.unknown([dynamic raw])` | `Unknown error occurred` | Catch-all for unexpected exceptions |
| `network` | `RzApiError.network([dynamic raw])` | `Network error. Please check your connection.` | No internet, `SocketException`, connection timeout |
| `server` | `RzApiError.server({int? statusCode, String? message, dynamic raw})` | `Server error occurred` | API errors with status code and response body |

Helper Example:

| Code | Result |
|---|---|
| `RzApiError.network()` | `message = Network error...` |
| `RzApiError.unknown(ex)` | `message = Unknown error occurred`, `raw = ex` |
| `RzApiError.server(statusCode: 401, message: 'Unauthorized')` | `401 Unauthorized error` |

### Supported Platforms:

| Platform | Supported | Notes |
| :--- | :---: | :--- |
| **Android** | ✅ | Fully supported |
| **iOS** | ✅ | Fully supported |
| **Web** | ✅ | Fully supported, web-safe error mapping |
| **Windows** | ✅ | Fully supported |
| **macOS** | ✅ | Fully supported |
| **Linux** | ✅ | Fully supported |

# Author

Rz Rasel