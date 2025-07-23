# AMap Flutter Plugin (高德地图 Flutter 插件)

这个 Flutter 插件允许您在 Flutter 应用中集成高德地图 SDK，支持 Android 和 iOS 平台。

## 功能特性

- 🗺️ 地图展示
- 📍 添加/移除标记点
- 📱 获取当前定位
- 🔄 控制相机位置和动画
- ⚙️ 自定义地图外观和行为

## 安装

添加依赖到您的`pubspec.yaml`文件：

```yaml
dependencies:
  amap_flutter: ^0.0.1
```

### Android 平台配置

1. 在 `AndroidManifest.xml` 中添加必要的权限：

```xml
<!-- 访问网络获取地图服务 -->
<uses-permission android:name="android.permission.INTERNET" />
<!-- 获取网络状态 -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<!-- 获取wifi网络信息 -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<!-- 写入外部存储 -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<!-- 获取精确定位 -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<!-- 获取粗略定位 -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

2. 在 app 级别的 `build.gradle` 文件中确保已设置正确的 minSdkVersion：

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### iOS 平台配置

1. 在 `Info.plist` 文件中添加定位权限描述：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要访问您的位置信息以提供定位服务</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>需要始终访问您的位置信息以提供持续的定位服务</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要访问您的位置信息以提供定位服务</string>
```

## 使用方法

### 初始化

在使用地图功能前，您需要初始化 SDK 并设置 API Key：

```dart
import 'package:amap_flutter/amap_flutter.dart';

// 初始化高德地图
await AmapFlutter.setApiKey(
  androidKey: '您的Android平台Key',
  iosKey: '您的iOS平台Key',
);

// 设置隐私合规（必须在SDK初始化之前调用）
await AmapFlutter.updatePrivacyShow(
  hasContains: true, // 隐私政策是否包含高德开平隐私政策
  hasShow: true,     // 隐私政策是否弹窗展示告知用户
);

await AmapFlutter.updatePrivacyAgree(hasAgree: true); // 用户是否同意隐私政策
```

### 显示地图

```dart
// 初始相机位置（北京天安门）
final CameraPosition _initialCameraPosition = CameraPosition(
  target: LatLng(latitude: 39.908823, longitude: 116.397470),
  zoom: 14,
);

// 在Widget树中添加地图
AmapWidget(
  initialCameraPosition: _initialCameraPosition,
  myLocationEnabled: true,        // 是否显示我的位置
  myLocationButtonEnabled: true,  // 是否显示我的位置按钮
  compassEnabled: true,           // 是否显示指南针
  scaleControlsEnabled: true,     // 是否显示比例尺控件
  onMapCreated: () {
    print('地图创建完成');
  },
  onTap: (LatLng latLng) {
    print('点击地图位置: $latLng');
  },
),
```

### 添加标记点

```dart
// 创建标记点集合
final Set<Marker> markers = {
  Marker(
    markerId: 'marker_1',
    position: LatLng(latitude: 39.908823, longitude: 116.397470),
    title: '天安门',
    snippet: '中国北京市中心的广场',
  ),
};

// 在地图中使用标记点
AmapWidget(
  initialCameraPosition: _initialCameraPosition,
  markers: markers,
  // 其他属性...
),
```

### 控制相机位置

获取控制器并移动相机：

```dart
AmapWidgetController? _controller;

// 移动相机
void _goToShanghai() {
  final CameraPosition position = CameraPosition(
    target: LatLng(latitude: 31.230378, longitude: 121.473658),
    zoom: 14,
  );

  _controller?.animateCamera(position);
}
```

## 获取高德地图 API Key

请访问[高德开放平台官网](https://lbs.amap.com/)注册并申请相应的 Key。

## 示例

查看[示例应用](example)了解更多使用方法。

## 许可证

本项目基于 MIT 许可证开源，详见[LICENSE](LICENSE)文件。
