import 'package:flutter_test/flutter_test.dart';
import 'package:amap_flutter/amap_flutter.dart';
import 'package:amap_flutter/amap_flutter_platform_interface.dart';
import 'package:amap_flutter/amap_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAmapFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AmapFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AmapFlutterPlatform initialPlatform = AmapFlutterPlatform.instance;

  test('$MethodChannelAmapFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAmapFlutter>());
  });

  test('getPlatformVersion', () async {
    AmapFlutter amapFlutterPlugin = AmapFlutter();
    MockAmapFlutterPlatform fakePlatform = MockAmapFlutterPlatform();
    AmapFlutterPlatform.instance = fakePlatform;

    expect(await amapFlutterPlugin.getPlatformVersion(), '42');
  });
}
