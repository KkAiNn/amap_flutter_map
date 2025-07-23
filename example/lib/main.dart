import 'package:flutter/material.dart';
import 'package:amap_flutter/amap_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '高德地图示例',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '高德地图示例'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 设置北京天安门的位置作为初始地图中心点
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(latitude: 39.908823, longitude: 116.397470),
    zoom: 14,
  );

  // 定义一组标记点
  final Set<Marker> _markers = {};

  // 地图控制器
  AmapWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _initAMap();

    // 添加一个标记点
    _markers.add(
      Marker(
        markerId: 'marker_1',
        position: const LatLng(latitude: 39.908823, longitude: 116.397470),
        title: '天安门',
        snippet: '中国北京市中心的广场',
      ),
    );
  }

  // 初始化地图
  Future<void> _initAMap() async {
    // 设置隐私合规
    await AmapFlutter.updatePrivacyShow(hasContains: true, hasShow: true);

    await AmapFlutter.updatePrivacyAgree(hasAgree: true);
    // 在这里设置您的高德地图 API Key
    await AmapFlutter.setApiKey(
      // 这里需要替换为您自己的Key
      androidKey: 'aa2bc9c450a0cf85d4c50f169f548a6c',
      iosKey: '您的iOS平台Key',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: AmapWidget(
              initialCameraPosition: _initialCameraPosition,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              scaleControlsEnabled: true,
              onMapCreated: (controller) {
                debugPrint('地图创建完成');
                // 初始化地图控制器
                _controller = controller;
              },
              onTap: (LatLng latLng) {
                _addMarker(latLng);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _goToBeijing,
                  child: const Text('北京'),
                ),
                ElevatedButton(
                  onPressed: _goToShanghai,
                  child: const Text('上海'),
                ),
                ElevatedButton(
                  onPressed: _goToGuangzhou,
                  child: const Text('广州'),
                ),
                ElevatedButton(
                  onPressed: _clearMarkers,
                  child: const Text('清除标记'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 添加标记点
  void _addMarker(LatLng position) {
    final String markerId = 'marker_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _markers.add(
        Marker(
          markerId: markerId,
          position: position,
          title: '新标记点',
          snippet: '位置: ${position.latitude}, ${position.longitude}',
        ),
      );
    });
  }

  // 前往北京
  void _goToBeijing() {
    final CameraPosition position = CameraPosition(
      target: const LatLng(latitude: 39.908823, longitude: 116.397470),
      zoom: 14,
    );

    _controller?.animateCamera(position);
  }

  // 前往上海
  void _goToShanghai() {
    final CameraPosition position = CameraPosition(
      target: const LatLng(latitude: 31.230378, longitude: 121.473658),
      zoom: 14,
    );

    _controller?.animateCamera(position);
  }

  // 前往广州
  void _goToGuangzhou() {
    final CameraPosition position = CameraPosition(
      target: const LatLng(latitude: 23.129110, longitude: 113.264381),
      zoom: 14,
    );

    _controller?.animateCamera(position);
  }

  // 清除所有标记点
  void _clearMarkers() {
    setState(() {
      _markers.clear();
    });
  }
}
