import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'amap_flutter_platform_interface.dart';

/// An implementation of [AmapFlutterPlatform] that uses method channels.
class MethodChannelAmapFlutter extends AmapFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('amap_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> setApiKey({
    required String androidKey,
    required String iosKey,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'setApiKey',
        <String, dynamic>{'androidKey': androidKey, 'iosKey': iosKey},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('设置API Key失败: $e');
      return false;
    }
  }

  @override
  Future<bool> updatePrivacyShow({
    required bool hasContains,
    required bool hasShow,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'updatePrivacyShow',
        <String, dynamic>{'hasContains': hasContains, 'hasShow': hasShow},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('隐私合规设置失败: $e');
      return false;
    }
  }

  @override
  Future<bool> updatePrivacyAgree({required bool hasAgree}) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'updatePrivacyAgree',
        <String, dynamic>{'hasAgree': hasAgree},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('隐私合规设置失败: $e');
      return false;
    }
  }
}
