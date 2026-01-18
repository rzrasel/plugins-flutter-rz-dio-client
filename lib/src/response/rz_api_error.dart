/// Represents an API error with details about the failure.
class RzApiError {
  /// The HTTP status code associated with the server error, if available.
  final int? statusCode;

  /// A human-readable message describing the error.
  final String message;

  /// Raw data from the error response, such as the original exception or response body.
  final dynamic raw;

  /// Creates a new [RzApiError] instance.
  ///
  /// - [statusCode]: Optional HTTP status code.
  /// - [message]: Required error message.
  /// - [raw]: Optional raw error data.
  const RzApiError({
    this.statusCode,
    required this.message,
    this.raw,
  });

  /// Factory constructor for an unknown error.
  ///
  /// - [raw]: Optional raw error data.
  ///
  /// Returns an [RzApiError] with a generic "Unknown error occurred" message.
  factory RzApiError.unknown([dynamic raw]) {
    return RzApiError(
      message: 'Unknown error occurred',
      raw: raw,
    );
  }

  /// Factory constructor for a network-related error.
  ///
  /// - [raw]: Optional raw error data.
  ///
  /// Returns an [RzApiError] with a "Network error. Please check your connection." message.
  factory RzApiError.network([dynamic raw]) {
    return RzApiError(
      message: 'Network error. Please check your connection.',
      raw: raw,
    );
  }

  /// Factory constructor for a server-related error.
  ///
  /// - [statusCode]: Optional HTTP status code.
  /// - [message]: Optional custom error message; defaults to "Server error occurred".
  /// - [raw]: Optional raw error data, such as the response body.
  ///
  /// Returns an [RzApiError] with the provided details.
  factory RzApiError.server({
    int? statusCode,
    String? message,
    dynamic raw,
  }) {
    return RzApiError(
      statusCode: statusCode,
      message: message ?? 'Server error occurred',
      raw: raw,
    );
  }
}