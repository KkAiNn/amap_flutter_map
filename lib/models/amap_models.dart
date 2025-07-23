import 'package:flutter/material.dart';

/// 地图类型
enum MapType {
  /// 标准地图
  normal,

  /// 卫星地图
  satellite,

  /// 夜间模式
  night,

  /// 导航模式
  navi,

  /// 公交模式
  bus,
}

/// 位置信息类
class LatLng {
  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  factory LatLng.fromMap(Map<String, dynamic> map) {
    return LatLng(latitude: map['latitude'], longitude: map['longitude']);
  }

  @override
  String toString() => 'LatLng(latitude: $latitude, longitude: $longitude)';
}

/// 地图相机位置
class CameraPosition {
  /// 目标位置
  final LatLng target;

  /// 缩放级别
  final double zoom;

  /// 倾斜角度
  final double tilt;

  /// 方位角
  final double bearing;

  const CameraPosition({
    required this.target,
    this.zoom = 10.0,
    this.tilt = 0.0,
    this.bearing = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'target': target.toMap(),
      'zoom': zoom,
      'tilt': tilt,
      'bearing': bearing,
    };
  }

  factory CameraPosition.fromMap(Map<String, dynamic> map) {
    return CameraPosition(
      target: LatLng.fromMap(map['target']),
      zoom: map['zoom'] ?? 10.0,
      tilt: map['tilt'] ?? 0.0,
      bearing: map['bearing'] ?? 0.0,
    );
  }
}

/// 标记点
class Marker {
  /// 标记点ID
  final String markerId;

  /// 标记点位置
  final LatLng position;

  /// 标记点图标
  final String? icon;

  /// 标记点标题
  final String? title;

  /// 标记点副标题
  final String? snippet;

  /// 是否可拖动
  final bool draggable;

  /// 是否平贴地图
  final bool flat;

  /// 锚点
  final Offset anchor;

  /// 点击事件回调
  final VoidCallback? onTap;

  /// 拖动结束事件回调
  final ValueChanged<LatLng>? onDragEnd;

  const Marker({
    required this.markerId,
    required this.position,
    this.icon,
    this.title,
    this.snippet,
    this.draggable = false,
    this.flat = false,
    this.anchor = const Offset(0.5, 1.0),
    this.onTap,
    this.onDragEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'markerId': markerId,
      'position': position.toMap(),
      'icon': icon,
      'title': title,
      'snippet': snippet,
      'draggable': draggable,
      'flat': flat,
      'anchor': {'x': anchor.dx, 'y': anchor.dy},
    };
  }
}

/// 定位信息
class Location {
  /// 位置
  final LatLng latLng;

  /// 精确度，单位米
  final double accuracy;

  /// 速度，单位米/秒
  final double speed;

  /// 方向，范围为0-360度
  final double bearing;

  /// 海拔高度，单位米
  final double altitude;

  /// 时间戳
  final int time;

  /// 城市编码
  final String? cityCode;

  /// 城市名称
  final String? city;

  /// 区域编码
  final String? adCode;

  /// 区域名称
  final String? district;

  /// 地址
  final String? address;

  /// POI名称
  final String? poiName;

  /// 街道名称
  final String? street;

  /// 街道号码
  final String? streetNum;

  const Location({
    required this.latLng,
    this.accuracy = 0.0,
    this.speed = 0.0,
    this.bearing = 0.0,
    this.altitude = 0.0,
    this.time = 0,
    this.cityCode,
    this.city,
    this.adCode,
    this.district,
    this.address,
    this.poiName,
    this.street,
    this.streetNum,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latLng: LatLng.fromMap(map['latLng']),
      accuracy: map['accuracy'] ?? 0.0,
      speed: map['speed'] ?? 0.0,
      bearing: map['bearing'] ?? 0.0,
      altitude: map['altitude'] ?? 0.0,
      time: map['time'] ?? 0,
      cityCode: map['cityCode'],
      city: map['city'],
      adCode: map['adCode'],
      district: map['district'],
      address: map['address'],
      poiName: map['poiName'],
      street: map['street'],
      streetNum: map['streetNum'],
    );
  }
}

/// 地图边距设置
class EdgePadding {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const EdgePadding({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  Map<String, dynamic> toMap() {
    return {'left': left, 'top': top, 'right': right, 'bottom': bottom};
  }
}
