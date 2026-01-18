# RzAuthInterceptor

`RzAuthInterceptor` is a Dio interceptor that automatically adds an `Authorization` Bearer token header to outgoing HTTP requests and handles `401 Unauthorized` responses using a callback. It simplifies authentication management in API clients by centralising token injection and providing a hook for token expiry or invalid credentials.

## Short Description

The `RzAuthInterceptor` attaches a Bearer token to the `Authorization` header of every request when a token is provided. It also listens for `401` status codes in responses and invokes a callback (e.g., to refresh the token, log out, or navigate to login). This interceptor keeps authentication logic clean and reusable across your entire Dio client setup.

## Features

- **Automatic Token Injection:** Adds an `Authorization: Bearer <token>` header to all requests when `authToken` is set.
- **Customisable Header:** Configure the header key (default `'Authorization'`) and prefix (default `'Bearer'`).
- **401 Response Handling:** Detects `401` status codes and triggers an `onUnauthorized` callback for custom error recovery.
- **Flexible Callback:** Use `onUnauthorized` to implement token refresh, logout, or navigation logic.
- **Lightweight:** Simple, focused interceptor with minimal dependencies.
- **Null‑safe:** Supports nullable tokens; if `authToken` is `null` or empty, no header is added.

## Basic Use

Add `RzAuthInterceptor` to your Dio instance with a token.

```dart
import 'package:dio/dio.dart';
import 'rz_auth_interceptor.dart';

void main() {
  final dio = Dio();
  dio.interceptors.add(
    RzAuthInterceptor(authToken: 'your-access-token-here'),
  );

  // All requests will now include the Authorization header
  dio.get('https://api.example.com/protected');
}
```

```dart
import 'package:dio/dio.dart';
import 'package:rz_dio_client/rz_dio_client.dart';

final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));

// Simple usage
dio.interceptors.add(
  RzAuthInterceptor(
    authToken: 'your_jwt_token_here',
    onUnauthorized: () {
      print('401 - Token expired, redirect to login');
    },
  ),
);

// With RzDioProvider
final dioProvider = RzDioProvider(
  baseUrl: 'https://api.example.com',
  dio: dio,
);

final dioService = RzDioService();

// All requests via dioService will now have Authorization header
final response = await dioService.request<User>(
  (token) => dioProvider.get('/user/profile', cancelToken: token),
  (json) => User.fromJson(json),
);
```

### All Properties

RzAuthInterceptor

| Property | Type | Default | Description |
|---|---|---|---|
| `authToken` | `String?` | `null` | JWT/access token to inject. If `null` or empty after trimming, no authorization header is added |
| `onUnauthorized` | `UnauthorizedCallback?` (`void Function()?`) | `null` | Callback invoked when `err.response?.statusCode == 401`. Useful for logout, token refresh, or navigation |
| `authorization` | `String` | `'Authorization'` | HTTP header key for authentication. Can be changed for custom headers such as `X-Auth-Token` |
| `bearerPrefix` | `String` | `'Bearer'` | Prefix added before the token. Default produces `Bearer <token>`. Use `Token` or an empty string when required |

Methods (from Interceptor)

| Method | Description |
|---|---|
| `onRequest(RequestOptions, RequestInterceptorHandler)` | Injects the `Authorization` header when `authToken` is valid, then calls `handler.next(options)` |
| `onError(DioException, ErrorInterceptorHandler)` | Checks whether `statusCode == 401`, invokes `onUnauthorized` when applicable, then calls `handler.next(err)` |

TypeDef

| Type | Signature | Description |
|---|---|---|
| `UnauthorizedCallback` | `void Function()` | Callback invoked when a `401 Unauthorized` response is received |

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

# Author:
Rz Rasel