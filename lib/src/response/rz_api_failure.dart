import 'rz_api_error.dart';
import 'rz_api_response.dart';

/// Represents a failure state in the sealed [RzApiResponse] hierarchy.
///
/// This class holds an [RzApiError] instance detailing the nature of the failure,
/// such as network issues, server errors, or unknown exceptions. It is used in
/// API response handling to propagate errors in a type-safe manner.
class RzApiFailure<T> extends RzApiResponse<T> {
  /// The error details associated with this failure response.
  final RzApiError error;

  /// Creates a new [RzApiFailure] instance.
  ///
  /// - [error]: The [RzApiError] describing the failure.
  const RzApiFailure(this.error);

  @override
  R when<R>({
    /// Callback invoked when the response is a success, receiving the success data.
    required R Function(T data) success,
    /// Callback invoked when the response is a failure, receiving the error details.
    required R Function(RzApiError error) failure,
  }) {
    return failure(error);
  }
}