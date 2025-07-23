// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'amap_flutter_platform_interface.dart';
export 'models/amap_models.dart';
export 'widgets/amap_widget.dart';

class AmapFlutter {
  static const MethodChannel _channel = MethodChannel('amap_flutter');

  /// 获取平台版本信息
  Future<String?> getPlatformVersion() {
    return AmapFlutterPlatform.instance.getPlatformVersion();
  }

  /// 设置高德地图API Key
  /// [androidKey] Android平台的Key
  /// [iosKey] iOS平台的Key
  static Future<bool> setApiKey({
    required String androidKey,
    required String iosKey,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'setApiKey',
        <String, dynamic>{'androidKey': androidKey, 'iosKey': iosKey},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('设置API Key失败: $e');
      return false;
    }
  }

  /// 隐私合规接口设置
  /// [hasContains] 隐私政策是否包含高德开平隐私政策
  /// [hasShow] 隐私政策是否弹窗展示告知用户
  /// [hasAgree] 用户是否同意隐私政策
  static Future<bool> updatePrivacyShow({
    required bool hasContains,
    required bool hasShow,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'updatePrivacyShow',
        <String, dynamic>{'hasContains': hasContains, 'hasShow': hasShow},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('隐私合规设置失败: $e');
      return false;
    }
  }

  static Future<bool> updatePrivacyAgree({required bool hasAgree}) async {
    try {
      final result = await _channel.invokeMethod<bool>(
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
