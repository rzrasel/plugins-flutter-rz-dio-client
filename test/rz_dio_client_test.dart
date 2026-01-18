import 'package:flutter_test/flutter_test.dart';
import 'package:rz_dio_client/rz_dio_client_platform_interface.dart';
import 'package:rz_dio_client/rz_dio_client_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRzDioClientPlatform
    with MockPlatformInterfaceMixin
    implements RzDioClientPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RzDioClientPlatform initialPlatform = RzDioClientPlatform.instance;

  test('$MethodChannelRzDioClient is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRzDioClient>());
  });

  test('getPlatformVersion', () async {
    //RzDioClient rzDioClientPlugin = RzDioClient();
    MockRzDioClientPlatform fakePlatform = MockRzDioClientPlatform();
    RzDioClientPlatform.instance = fakePlatform;

    //expect(await rzDioClientPlugin.getPlatformVersion(), '42');
  });
}
