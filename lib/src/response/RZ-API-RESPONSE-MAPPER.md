# RzApiResponseMapper

`RzApiResponseMapper` is a Dart extension that adds a `map` method to `RzApiResponse<T>`. It allows you to transform the success value of an API response from one type to another while preserving any failure state – a convenient utility for mapping data transfer objects (DTOs) to domain models in repository layers.

## Short Description

The `RzApiResponseMapper` extension provides a functional `map` operation on `RzApiResponse` instances. When the response is a success, it applies a mapper function to the contained data and returns a new success response with the transformed type. If the response is a failure, it propagates the original error unchanged. This eliminates boilerplate `when` calls for simple data transformations and keeps your repository code clean and expressive.

## Features

- **Functional Transformation:** Seamlessly maps the success data from one type to another.
- **Preserves Failure States:** Errors are passed through without modification.
- **Composable:** Works great in chains and with other functional operations.
- **Type‑Safe:** The mapper function ensures compile‑time type safety.
- **Lightweight:** Simple extension with no additional dependencies.

## Basic Use

Given an `RzApiResponse` with a data type, use `.map()` to transform the success payload.

```dart
import 'rz_api_response.dart';
import 'rz_api_response_mapper.dart';

// Example DTO and domain model
class UserDto {
  final String name;
  UserDto(this.name);
}

class User {
  final String fullName;
  User(this.fullName);
}

// Assume we have a response from an API
RzApiResponse<UserDto> response = RzApiResponse.success(UserDto('Rz Rasel'));

// Map DTO to domain model
RzApiResponse<User> mapped = response.map((dto) => User(dto.name));

mapped.when(
  success: (user) => print('User: ${user.fullName}'),
  failure: (error) => print('Error: ${error.message}'),
);
// Output: User: Rz Rasel
```

### All Properties & Methods

RzApiResponseMapper<T> Extension

| Parameter | Type | Description |
|---|---|---|
| `mapper` | `R Function(T data)` | Function that converts successful data from type `T` to type `R`. Invoked only when the response is successful. |

Returns: RzApiResponse<R> - Either mapped success or original failure.

### Supported Platforms

Pure Dart extension - no platform-specific code.

| Platform | Supported | Notes |
| :--- | :---: | :--- |
| **Android** | ✅ | Fully supported |
| **iOS** | ✅ | Fully supported |
| **Web** | ✅ | Fully supported, web-safe error mapping |
| **Windows** | ✅ | Fully supported |
| **macOS** | ✅ | Fully supported |
| **Linux** | ✅ | Fully supported |
- Any platform where Dart/Flutter runs

Requires: rz_dio_client or rz_api_response package. Compatible with all state management solutions.

# Author

Rz Rasel