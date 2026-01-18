import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'rz_dio_client_method_channel.dart';

abstract class RzDioClientPlatform extends PlatformInterface {
  /// Constructs a RzDioClientPlatform.
  RzDioClientPlatform() : super(token: _token);

  static final Object _token = Object();

  static RzDioClientPlatform _instance = MethodChannelRzDioClient();

  /// The default instance of [RzDioClientPlatform] to use.
  ///
  /// Defaults to [MethodChannelRzDioClient].
  static RzDioClientPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RzDioClientPlatform] when
  /// they register themselves.
  static set instance(RzDioClientPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
