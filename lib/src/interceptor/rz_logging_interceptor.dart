import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// A customized Dio [Interceptor] for logging HTTP requests and responses
/// using the [pretty_dio_logger] package.
///
/// This class extends [PrettyDioLogger] with predefined options enabled for
/// comprehensive logging: request headers and body, response headers and body,
/// errors, and a compact output format. It is designed for development and
/// debugging purposes, providing human-readable logs of API interactions.
class RzLoggingInterceptor extends PrettyDioLogger {
  /// Creates a new [RzLoggingInterceptor] with all logging options enabled.
  ///
  /// - Logs request headers and body for outgoing requests.
  /// - Logs response headers and body for incoming responses.
  /// - Logs errors for failed requests.
  /// - Uses a compact format to reduce log verbosity while maintaining readability.
  ///
  /// This constructor configures the parent [PrettyDioLogger] with these settings
  /// for immediate use as a Dio interceptor.
  RzLoggingInterceptor()
      : super(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    compact: true,
  );
}