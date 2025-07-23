import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'amap_flutter_method_channel.dart';

abstract class AmapFlutterPlatform extends PlatformInterface {
  /// Constructs a AmapFlutterPlatform.
  AmapFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AmapFlutterPlatform _instance = MethodChannelAmapFlutter();

  /// The default instance of [AmapFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAmapFlutter].
  static AmapFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AmapFlutterPlatform] when
  /// they register themselves.
  static set instance(AmapFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// 设置高德地图API Key
  /// [androidKey] Android平台的Key
  /// [iosKey] iOS平台的Key
  Future<bool> setApiKey({required String androidKey, required String iosKey}) {
    throw UnimplementedError('setApiKey() has not been implemented.');
  }

  /// 隐私合规接口设置
  /// [hasContains] 隐私政策是否包含高德开平隐私政策
  /// [hasShow] 隐私政策是否弹窗展示告知用户
  Future<bool> updatePrivacyShow({
    required bool hasContains,
    required bool hasShow,
  }) {
    throw UnimplementedError('updatePrivacyShow() has not been implemented.');
  }

  /// 隐私合规接口设置
  /// [hasAgree] 用户是否同意隐私政策
  Future<bool> updatePrivacyAgree({required bool hasAgree}) {
    throw UnimplementedError('updatePrivacyAgree() has not been implemented.');
  }
}
