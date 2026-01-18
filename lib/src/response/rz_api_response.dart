import 'rz_api_error.dart';
import 'rz_api_success.dart';
import 'rz_api_failure.dart';

/// A sealed abstract class representing the result of an API request, which can
/// either be a successful response with data or a failure with an error.
///
/// This class enforces exhaustive pattern matching via the [when] method,
/// allowing consumers to handle both success and failure cases in a type-safe
/// manner. It is typically used as the return type for API service methods to
/// encapsulate responses uniformly.
abstract class RzApiResponse<T> {
  /// Creates a new [RzApiResponse] instance.
  ///
  /// This is an abstract constructor; concrete subclasses will implement it.
  const RzApiResponse();

  /// Performs pattern matching on the response, invoking the appropriate
  /// callback based on whether it is a success or failure.
  ///
  /// - [success]: Callback invoked if this is a successful response, receiving
  ///   the deserialized data of type [T].
  /// - [failure]: Callback invoked if this is a failed response, receiving the
  ///   [RzApiError] details.
  ///
  /// Returns the result of the invoked callback.
  R when<R>({
    required R Function(T data) success,
    required R Function(RzApiError error) failure,
  });

  /// Factory constructor for a successful API response.
  ///
  /// - [data]: The deserialized data of type [T] from the API response.
  ///
  /// Returns an [RzApiSuccess<T>] instance.
  factory RzApiResponse.success(T data) = RzApiSuccess<T>;

  /// Factory constructor for a failed API response.
  ///
  /// - [error]: The [RzApiError] describing the failure.
  ///
  /// Returns an [RzApiFailure<T>] instance.
  factory RzApiResponse.failure(RzApiError error) = RzApiFailure<T>;
}