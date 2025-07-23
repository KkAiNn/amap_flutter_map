import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/amap_models.dart';

/// 高德地图控件
class AmapWidget extends StatefulWidget {
  /// 初始相机位置
  final CameraPosition initialCameraPosition;

  /// 地图类型
  final MapType mapType;

  /// 是否显示室内地图
  final bool showIndoorMap;

  /// 是否显示建筑物
  final bool showBuildings;

  /// 是否显示文本标注
  final bool showLabels;

  /// 是否显示交通状况
  final bool showTraffic;

  /// 是否支持缩放手势
  final bool zoomGesturesEnabled;

  /// 是否支持滑动手势
  final bool scrollGesturesEnabled;

  /// 是否支持旋转手势
  final bool rotateGesturesEnabled;

  /// 是否支持倾斜手势
  final bool tiltGesturesEnabled;

  /// 是否启用定位
  final bool myLocationEnabled;

  /// 是否显示定位按钮
  final bool myLocationButtonEnabled;

  /// 是否显示缩放控件
  final bool zoomControlsEnabled;

  /// 是否显示指南针
  final bool compassEnabled;

  /// 是否显示比例尺控件
  final bool scaleControlsEnabled;

  /// 地图加载完成回调
  final Function(AmapWidgetController)? onMapCreated;

  /// 相机移动开始回调
  final VoidCallback? onCameraMoveStarted;

  /// 相机移动回调
  final ValueChanged<CameraPosition>? onCameraMove;

  /// 相机移动结束回调
  final VoidCallback? onCameraIdle;

  /// 地图点击回调
  final ValueChanged<LatLng>? onTap;

  /// 地图长按回调
  final ValueChanged<LatLng>? onLongPress;

  /// 地图标记点集合
  final Set<Marker> markers;

  /// 手势识别工厂
  final Factory<OneSequenceGestureRecognizer>? gestureRecognizerFactory;

  const AmapWidget({
    Key? key,
    required this.initialCameraPosition,
    this.mapType = MapType.normal,
    this.showIndoorMap = false,
    this.showBuildings = true,
    this.showLabels = true,
    this.showTraffic = false,
    this.zoomGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.rotateGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = true,
    this.compassEnabled = false,
    this.scaleControlsEnabled = false,
    this.onMapCreated,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.markers = const <Marker>{},
    this.gestureRecognizerFactory,
  }) : super(key: key);

  @override
  State<AmapWidget> createState() => _AmapWidgetState();
}

class _AmapWidgetState extends State<AmapWidget> {
  final Completer<int> _idCompleter = Completer<int>();
  final _markersToAdd = <Marker>{};
  final _markersToRemove = <String>{};
  Map<String, Marker> _markers = <String, Marker>{};
  int? _mapId;
  AmapWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _markers = Map<String, Marker>.fromEntries(
      widget.markers.map(
        (Marker marker) => MapEntry<String, Marker>(marker.markerId, marker),
      ),
    );
  }

  @override
  void didUpdateWidget(AmapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Set<Marker> markersToAdd = <Marker>{};
    for (final Marker marker in widget.markers) {
      final String markerId = marker.markerId;
      final Marker? oldMarker = _markers[markerId];
      if (oldMarker == null) {
        markersToAdd.add(marker);
      } else {
        _markers[markerId] = marker;
      }
    }

    final Set<String> markersToRemove = <String>{};
    for (final Marker marker in oldWidget.markers) {
      final String markerId = marker.markerId;
      if (!widget.markers.any((Marker m) => m.markerId == markerId)) {
        markersToRemove.add(markerId);
        _markers.remove(markerId);
      }
    }

    if (_mapId != null) {
      _updateMarkers(markersToAdd, markersToRemove);
    } else {
      _markersToAdd.addAll(markersToAdd);
      _markersToRemove.addAll(markersToRemove);
    }

    if (widget.markers.isEmpty) {
      _clearMarkers();
    }
  }

  @override
  void dispose() {
    super.dispose();
    // 清理控制器资源
    _controller?.dispose();
    _controller = null;
  }

  Future<void> _updateMarkers(
    Set<Marker> markersToAdd,
    Set<String> markersToRemove,
  ) async {
    if (markersToAdd.isNotEmpty) {
      final List<Map<String, dynamic>> markersToAddList = markersToAdd
          .map((Marker marker) => marker.toMap())
          .toList();

      // await AmapWidgetController.channel(mapId).invokeMethod<void>(
      //   'markers#addMarkers',
      //   <String, dynamic>{'mapId': mapId, 'markers': markersToAddList},
      // );
      _controller?.addMarkers(markersToAddList);
    }

    if (markersToRemove.isNotEmpty) {
      // await AmapWidgetController.channel(mapId).invokeMethod<void>(
      //   'markers#removeMarkers',
      //   <String, dynamic>{
      //     'mapId': mapId,
      //     'markerIds': markersToRemove.toList(),
      //   },
      // );
      _controller?.removeMarkers(markersToRemove.toList());
    }
  }

  void _clearMarkers() async {
    _controller?.clearMarkers();
  }

  void _onPlatformViewCreated(int id) {
    _mapId = id;
    if (!_idCompleter.isCompleted) {
      _idCompleter.complete(id);

      if (_markersToAdd.isNotEmpty || _markersToRemove.isNotEmpty) {
        _updateMarkers(_markersToAdd, _markersToRemove);
        _markersToAdd.clear();
        _markersToRemove.clear();
      }

      _controller = AmapWidgetController(id);
      // 设置控制器的事件回调
      _controller!.setMapEventCallbacks(
        onMapCreated: () => widget.onMapCreated?.call(_controller!),
        onCameraMoveStarted: widget.onCameraMoveStarted,
        onCameraMove: widget.onCameraMove,
        onCameraIdle: widget.onCameraIdle,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': widget.initialCameraPosition.toMap(),
      'mapType': widget.mapType.index,
      'showIndoorMap': widget.showIndoorMap,
      'showBuildings': widget.showBuildings,
      'showLabels': widget.showLabels,
      'showTraffic': widget.showTraffic,
      'zoomGesturesEnabled': widget.zoomGesturesEnabled,
      'scrollGesturesEnabled': widget.scrollGesturesEnabled,
      'rotateGesturesEnabled': widget.rotateGesturesEnabled,
      'tiltGesturesEnabled': widget.tiltGesturesEnabled,
      'myLocationEnabled': widget.myLocationEnabled,
      'myLocationButtonEnabled': widget.myLocationButtonEnabled,
      'zoomControlsEnabled': widget.zoomControlsEnabled,
      'compassEnabled': widget.compassEnabled,
      'scaleControlsEnabled': widget.scaleControlsEnabled,
      'markers': widget.markers.map((Marker marker) => marker.toMap()).toList(),
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      // 在Android平台使用AndroidView
      return AndroidView(
        viewType: 'plugins.flutter.io/amap',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          widget.gestureRecognizerFactory ??
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
        },
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // 在iOS平台使用UiKitView
      return UiKitView(
        viewType: 'plugins.flutter.io/amap',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          widget.gestureRecognizerFactory ??
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
        },
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return Text('当前平台暂不支持: $defaultTargetPlatform');
  }
}

/// 地图控制器
class AmapWidgetController {
  static const prefix = 'plugins.flutter.io/amap';

  final int mapId;
  late final MethodChannel _methodChannel;
  VoidCallback? _onMapCreated;
  VoidCallback? _onCameraMoveStarted;
  ValueChanged<CameraPosition>? _onCameraMove;
  VoidCallback? _onCameraIdle;
  ValueChanged<LatLng>? _onTap;
  ValueChanged<LatLng>? _onLongPress;

  AmapWidgetController(this.mapId) {
    // 创建并设置方法通道处理器，确保与Native端一致
    _methodChannel = MethodChannel('${prefix}_$mapId');
    _methodChannel.setMethodCallHandler(_handleMethodCall);

    // 初始化时打印调试信息
    debugPrint(
      'AmapWidgetController创建: mapId=$mapId, channel=${_methodChannel.name}',
    );
  }

  static MethodChannel channel(int mapId) {
    return MethodChannel('${prefix}_$mapId');
  }

  /// 处理从原生端传递过来的方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    // 打印接收到的方法调用，用于调试
    debugPrint('AmapFlutter: 收到方法调用 - ${call.method} - ${call.arguments}');

    // 尝试处理不同格式的方法名
    if (call.method == 'map#onTap' || call.method == 'onMapTap') {
      if (_onTap != null) {
        try {
          final arguments = call.arguments;
          final positionMap = arguments['position'];
          final double latitude = positionMap['latitude'] as double;
          final double longitude = positionMap['longitude'] as double;
          debugPrint('AmapFlutter: 地图点击事件 - lat: $latitude, lng: $longitude');
          _onTap!(LatLng(latitude: latitude, longitude: longitude));
        } catch (e) {
          debugPrint('AmapFlutter: 处理地图点击事件出错 - $e');
        }
      } else {
        debugPrint('AmapFlutter: _onTap回调为空');
      }
      return;
    }

    switch (call.method) {
      case 'map#onLongPress':
        if (_onLongPress != null) {
          try {
            final Map<String, dynamic> arguments =
                call.arguments as Map<String, dynamic>;
            final Map<String, dynamic> positionMap =
                arguments['position'] as Map<String, dynamic>;
            final double latitude = positionMap['latitude'] as double;
            final double longitude = positionMap['longitude'] as double;
            debugPrint('AmapFlutter: 地图长按事件 - lat: $latitude, lng: $longitude');
            _onLongPress!(LatLng(latitude: latitude, longitude: longitude));
          } catch (e) {
            debugPrint('AmapFlutter: 处理地图长按事件出错 - $e');
          }
        }
        break;
      case 'camera#onMoveStarted':
        if (_onCameraMoveStarted != null) {
          _onCameraMoveStarted!();
        }
        break;
      case 'camera#onMove':
        if (_onCameraMove != null) {
          try {
            final Map<String, dynamic> arguments =
                call.arguments as Map<String, dynamic>;
            final Map<String, dynamic> cameraPositionMap =
                arguments['cameraPosition'] as Map<String, dynamic>;
            final CameraPosition cameraPosition = CameraPosition.fromMap(
              cameraPositionMap,
            );
            _onCameraMove!(cameraPosition);
          } catch (e) {
            debugPrint('AmapFlutter: 处理相机移动事件出错 - $e');
          }
        }
        break;
      case 'camera#onIdle':
        if (_onCameraIdle != null) {
          _onCameraIdle!();
        }
        break;
      default:
        debugPrint('AmapFlutter: 未处理的方法调用 - ${call.method}');
        break;
    }
  }

  /// 改变相机位置
  Future<void> moveCamera(CameraPosition position) async {
    await _methodChannel.invokeMethod<void>('camera#move', <String, dynamic>{
      'position': position.toMap(),
    });
  }

  /// 动画改变相机位置
  Future<void> animateCamera(
    CameraPosition position, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await _methodChannel.invokeMethod<void>('camera#animate', <String, dynamic>{
      'position': position.toMap(),
      'duration': duration.inMilliseconds,
    });
  }

  /// 获取当前位置信息
  Future<Location?> getCurrentLocation() async {
    final Map<String, dynamic>? locationMap = await _methodChannel
        .invokeMapMethod<String, dynamic>('map#getCurrentLocation');
    if (locationMap != null) {
      return Location.fromMap(locationMap);
    }
    return null;
  }

  /// 添加标记点
  Future<void> addMarkers(List<Map<String, dynamic>> marker) async {
    await _methodChannel.invokeMethod<void>(
      'markers#addMarkers',
      <String, dynamic>{'mapId': mapId, 'markers': marker},
    );
  }

  /// 移除标记点
  Future<void> removeMarkers(List<String> markerId) async {
    await _methodChannel.invokeMethod<void>(
      'markers#removeMarker',
      <String, dynamic>{'mapId': mapId, 'markerIds': markerId},
    );
  }

  /// 清空所有标记点
  Future<void> clearMarkers() async {
    await _methodChannel.invokeMethod<void>('markers#clear');
  }

  /// 设置地图事件回调
  void setMapEventCallbacks({
    VoidCallback? onMapCreated,
    VoidCallback? onCameraMoveStarted,
    ValueChanged<CameraPosition>? onCameraMove,
    VoidCallback? onCameraIdle,
    ValueChanged<LatLng>? onTap,
    ValueChanged<LatLng>? onLongPress,
  }) {
    _onMapCreated = onMapCreated;
    _onCameraMoveStarted = onCameraMoveStarted;
    _onCameraMove = onCameraMove;
    _onCameraIdle = onCameraIdle;
    _onTap = onTap;
    _onLongPress = onLongPress;

    // 如果有onMapCreated回调，则立即调用一次
    if (_onMapCreated != null) {
      _onMapCreated!();
    }
  }

  /// 清理资源
  void dispose() {
    // 移除方法通道处理器
    _methodChannel.setMethodCallHandler(null);
    debugPrint('AmapWidgetController已释放: mapId=$mapId');
  }
}
