import 'rz_api_error.dart';
import 'rz_api_response.dart';

/// Represents a success state in the sealed [RzApiResponse] hierarchy.
///
/// This class holds the deserialized data of type [T] from a successful API
/// response. It is used in API response handling to propagate successful results
/// in a type-safe manner.
class RzApiSuccess<T> extends RzApiResponse<T> {
  /// The deserialized data from the successful API response.
  final T data;

  /// Creates a new [RzApiSuccess] instance.
  ///
  /// - [data]: The data of type [T] obtained from the API response.
  const RzApiSuccess(this.data);

  @override
  R when<R>({
    /// Callback invoked when the response is a success, receiving the success data.
    required R Function(T data) success,
    /// Callback invoked when the response is a failure, receiving the error details.
    required R Function(RzApiError error) failure,
  }) {
    return success(data);
  }
}