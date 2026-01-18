import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rz_dio_client_platform_interface.dart';

/// An implementation of [RzDioClientPlatform] that uses method channels.
class MethodChannelRzDioClient extends RzDioClientPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rz_dio_client');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
