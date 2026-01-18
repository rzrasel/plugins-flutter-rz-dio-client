# RzCancelTokenManager

`RzCancelTokenManager` is a utility class that manages a single `CancelToken` instance for Dio HTTP requests. It provides lazy initialisation, cancellation with a reason, and reset functionality – simplifying request cancellation in scenarios like user navigation, timeouts, or component disposal.

## Short Description

The `RzCancelTokenManager` centralises the lifecycle of a `CancelToken`, ensuring that only one active token exists at a time. It lazily creates the token on first access, cancels it (clearing the reference), and allows resetting without cancellation. This is especially useful in Flutter applications where you want to cancel ongoing API calls when a screen is disposed or a new request starts.

## Features

- **Lazy Initialisation:** Creates the `CancelToken` only when first accessed.
- **Single Active Token:** Maintains one token at a time, preventing leaks or multiple cancellations.
- **Cancellation with Reason:** Cancel the token with an optional reason (default: `'Request cancelled'`).
- **Auto‑Clear After Cancel:** After cancellation, the internal reference is removed, ensuring the next access creates a fresh token.
- **Reset Capability:** Manually reset the token without cancelling – useful for reuse in a new request cycle.
- **Immutable State:** The `token` getter returns the current `CancelToken`; the manager handles its lifecycle.

## Basic Use

Create an instance of `RzCancelTokenManager` and use its `token` getter to pass a `CancelToken` to your Dio requests.

```dart
import 'package:dio/dio.dart';
import 'rz_cancel_token_manager.dart';

void main() async {
  final cancelManager = RzCancelTokenManager();

  try {
    final response = await Dio().get(
      'https://api.example.com/data',
      cancelToken: cancelManager.token,
    );
    print('Response: ${response.data}');
  } catch (e) {
    if (e is DioException && e.type == DioExceptionType.cancel) {
      print('Request was cancelled: ${e.message}');
    }
  }
}
```

```dart
import 'package:dio/dio.dart';
import 'package:rz_dio_client/rz_dio_client.dart';

class UserRemoteDao {
  UserRemoteDao(this._dioService, this._dioProvider);
  final RzDioService _dioService;
  final RzDioProvider _dioProvider;
  final _cancelManager = RzCancelTokenManager();

  Future<RzApiResponse<User>> getUser(int id) {
    return _dioService.request<User>(
      (token) => _dioProvider.get(
        '/users/$id',
        cancelToken: token,
      ),
      (json) => User.fromJson(json),
      cancelToken: _cancelManager.token, // Use managed token
    );
  }

  void cancelRequest() {
    _cancelManager.cancel('User left the screen');
  }
}

// In Widget / Cubit
@override
void dispose() {
  _cancelManager.cancel('Screen disposed');
  super.dispose();
}
```

### Full Feature Use

Complete example with CreateBatchLanguageRemoteDao and lifecycle handling.

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rz_dio_client/rz_dio_client.dart';

class CreateBatchLanguageRemoteDao {
  CreateBatchLanguageRemoteDao(this._dioService, this._dioProvider);
  final RzDioService _dioService;
  final RzDioProvider _dioProvider;

  // Dedicated manager per request type
  final _createBatchTokenManager = RzCancelTokenManager();

  Future<RzApiResponse<CreateBatchLanguageResponseEntity>> createBatchLanguage({
    required CreateBatchLanguageRequestEntity requestEntity,
  }) {
    return _dioService.request<CreateBatchLanguageResponseEntity>(
      (token) => _dioProvider.post(
        ApiConstant.createBatchLanguageUrl,
        data: requestEntity.toJson(),
        options: Options(responseType: ResponseType.json),
        cancelToken: token,
      ),
      (json) => CreateBatchLanguageResponseEntity.fromJson(json),
      cancelToken: _createBatchTokenManager.token,
    );
  }

  void cancelCreateBatch() {
    _createBatchTokenManager.cancel('Create batch cancelled by user');
  }

  void reset() {
    _createBatchTokenManager.reset();
  }
}

class CreateBatchScreen extends StatefulWidget {
  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _remoteDao = CreateBatchLanguageRemoteDao(RzDioService(), RzDioProvider(baseUrl: 'https://api.example.com'));

  @override
  void dispose() {
    // Automatically cancels ongoing request when user leaves screen
    _remoteDao.cancelCreateBatch();
    super.dispose();
  }

  Future<void> _onCreatePressed() async {
    final response = await _remoteDao.createBatchLanguage(
      requestEntity: CreateBatchLanguageRequestEntity(languages: ['en', 'bn']),
    );

    response.when(
      success: (data) => print('Created: ${data.batchId}'),
      failure: (error) {
        if (error.raw is DioException) {
          final dioError = error.raw as DioException;
          if (dioError.type == DioExceptionType.cancel) {
            print('Request was cancelled');
            return;
          }
        }
        print('Error: ${error.message}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: _onCreatePressed, child: Text('Create')),
          ElevatedButton(onPressed: _remoteDao.cancelCreateBatch, child: Text('Cancel')),
        ],
      ),
    );
  }
}
```

### Advance Use

#### 1. Search Debouncing with Auto-Cancel

```dart
class SearchRemoteDao {
  final _searchTokenManager = RzCancelTokenManager();
  final RzDioService _dioService;
  final RzDioProvider _dioProvider;
  SearchRemoteDao(this._dioService, this._dioProvider);

  Future<RzApiResponse<List<User>>> search(String query) async {
    // Cancel previous search request before starting new one
    _searchTokenManager.cancel('New search query: $query');
    
    return _dioService.request<List<User>>(
      (token) => _dioProvider.get('/search?q=$query', cancelToken: token),
      (json) => (json as List).map((e) => User.fromJson(e)).toList(),
      cancelToken: _searchTokenManager.token,
    );
  }
}
```

#### 2. One Manager for Multiple Requests (Shared Cancellation)

```dart
class DashboardRepository {
  final _dashboardCancelManager = RzCancelTokenManager();

  Future<void> loadAll() async {
    // All requests share same token - one cancel() cancels all
    final userFuture = _userDao.getUser(cancelToken: _dashboardCancelManager.token);
    final postsFuture = _postDao.getPosts(cancelToken: _dashboardCancelManager.token);
    
    await Future.wait([userFuture, postsFuture]);
  }

  void cancelAll() => _dashboardCancelManager.cancel('Dashboard closed');
}
```

#### 3. Reset Without Cancel (Reuse Cycle)

```dart
final manager = RzCancelTokenManager();

Future<void> makeRequest() async {
  // First request
  await api.call(cancelToken: manager.token);
  
  // Without reset, same token instance is reused (if not cancelled)
  // If you want fresh token for next independent cycle:
  manager.reset(); // Clears reference without cancelling
  
  await api.call(cancelToken: manager.token); // New token instance
}
```

#### 4. Handling Cancelled Error

```dart
response.when(
  success: (data) => handleData(data),
  failure: (error) {
    final raw = error.raw;
    if (raw is DioException && CancelToken.isCancel(raw)) {
      print('Cancelled reason: ${raw.message}');
      return;
    }
    showError(error.message);
  },
);
```

### All Properties Table

RzCancelTokenManager

| Member | Type | Description |
|---|---|---|
| `token` | `CancelToken` (getter) | Lazily creates a new `CancelToken` if `_token` is `null`. Otherwise, returns the existing instance. After `cancel()` or `reset()`, the next access returns a fresh token |
| `cancel([String reason])` | `void` | Cancels the current token if it exists and is not already cancelled. Uses the specified reason, defaulting to `'Request cancelled'`. Sets `_token` to `null` afterward. Safe to call multiple times |
| `reset()` | `void` | Resets `_token` to `null` without calling `cancel()`. Useful for forcing a new token for the next request cycle without triggering a cancellation error |
| `_token` | `CancelToken?` (private) | Internal nullable `CancelToken` instance managed by the class |

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