import 'package:dio/dio.dart';

/// A utility class for managing a single [CancelToken] instance used in Dio requests.
///
/// This manager provides lazy initialization of the token, cancellation with an
/// optional reason, and reset functionality. It is useful for handling request
/// cancellation in scenarios like user navigation away from a screen or timeout
/// conditions, ensuring only one token is active at a time and preventing
/// multiple cancellations.
class RzCancelTokenManager {
  /// The internal [CancelToken] instance, lazily initialized.
  CancelToken? _token;

  /// Getter for the [CancelToken].
  ///
  /// Lazily creates a new [CancelToken] if none exists. Subsequent calls
  /// return the same instance until cancelled or reset.
  ///
  /// Returns the current [CancelToken] instance.
  CancelToken get token {
    _token ??= CancelToken();
    return _token!;
  }

  /// Cancels the current [CancelToken] if it exists and is not already cancelled.
  ///
  /// After cancellation, the internal reference is cleared to allow for a new
  /// token on the next access.
  ///
  /// - [reason]: Optional reason for cancellation (default: 'Request cancelled').
  void cancel([String reason = 'Request cancelled']) {
    if (_token != null && !_token!.isCancelled) {
      _token!.cancel(reason);
    }
    _token = null;
  }

  /// Resets the internal [CancelToken] reference without cancelling it.
  ///
  /// This allows for a fresh token on the next [token] access, useful when
  /// reusing the manager for a new request cycle.
  void reset() {
    _token = null;
  }
}