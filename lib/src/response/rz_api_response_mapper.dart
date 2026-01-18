import 'package:rz_dio_client/rz_dio_client.dart';

/// Extension methods for transforming the success value of an [RzApiResponse].
///
/// The [map] method converts the successful response data from one type to
/// another while preserving the original response state.
///
/// - If the response is a success, the provided [mapper] function is applied to
///   the contained data and a new [RzApiResponse.success] is returned.
/// - If the response is a failure, the original [RzApiError] is propagated
///   unchanged as a new [RzApiResponse.failure].
///
/// This is especially useful in repository implementations for mapping data
/// layer models (DTOs) to domain layer models without duplicating success and
/// failure handling.
///
/// Example:
/// ```dart
/// final response = await remoteDao.getUser();
///
/// return response.map((data) => data.toDomain());
/// ```
extension RzApiResponseMapper<T> on RzApiResponse<T> {
  /// Transforms the success value of this [RzApiResponse] into another type.
  ///
  /// The [mapper] function is invoked only when the response represents a
  /// successful result. Failure responses are returned unchanged.
  ///
  /// - [mapper]: A function that converts the success value of type [T] into
  ///   a value of type [R].
  ///
  /// Returns a new [RzApiResponse<R>] containing either the mapped success
  /// value or the original failure.
  RzApiResponse<R> map<R>(
      R Function(T data) mapper,
      ) {
    return when(
      success: (data) => RzApiResponse.success(
        mapper(data),
      ),
      failure: (error) => RzApiResponse.failure(error),
    );
  }
}