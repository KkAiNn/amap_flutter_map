package com.example.amap_flutter

import android.content.Context
import android.os.Bundle
import android.view.View
import com.amap.api.maps.AMap
import com.amap.api.maps.AMapOptions
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.TextureMapView
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.MyLocationStyle
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.HashMap

class AmapPlatformView(
    private val context: Context,
    private val viewId: Int,
    private val creationParams: Map<String, Any>?,
    messenger: BinaryMessenger,
    private val plugin: AmapFlutterPlugin
) : PlatformView, MethodChannel.MethodCallHandler {

    private val mapView: TextureMapView
    private val aMap: AMap
    private val methodChannel: MethodChannel
    private val markersController: MarkersController

    init {
        mapView = TextureMapView(context)
        mapView.onCreate(Bundle())

        // 创建方法通道，确保与Flutter端一致
        methodChannel = MethodChannel(messenger, "plugins.flutter.io/amap_$viewId")
        methodChannel.setMethodCallHandler(this)
        
        // 初始化地图
        aMap = mapView.map
        
        // 初始化标记点控制器
        markersController = MarkersController(aMap, context)
        
        // 设置地图事件监听器
        setupMapListeners()
        
        // 应用创建参数
        applyCreationParams()
    }

    private fun setupMapListeners() {
        // 地图点击事件
        aMap.setOnMapClickListener { latLng ->
            val arguments = HashMap<String, Any>()
            val position = HashMap<String, Double>()
            position["latitude"] = latLng.latitude
            position["longitude"] = latLng.longitude
            arguments["position"] = position
            
            
            try {
                // 使用与Flutter端一致的方法名
                methodChannel.invokeMethod("map#onTap", arguments)
            } catch (e: Exception) {
                android.util.Log.e("AmapFlutter", "Error sending map#onTap event", e)
            }
        }
        
        // 地图长按事件
        aMap.setOnMapLongClickListener { latLng ->
            val arguments = HashMap<String, Any>()
            val position = HashMap<String, Double>()
            position["latitude"] = latLng.latitude
            position["longitude"] = latLng.longitude
            arguments["position"] = position
            
            methodChannel.invokeMethod("map#onLongPress", arguments)
        }
        
        // 相机变化开始事件
        aMap.setOnCameraChangeListener(object : AMap.OnCameraChangeListener {
            override fun onCameraChange(cameraPosition: CameraPosition?) {
                if (cameraPosition != null) {
                    val arguments = HashMap<String, Any>()
                    val cameraPositionMap = HashMap<String, Any>()
                    
                    val targetMap = HashMap<String, Any>()
                    targetMap["latitude"] = cameraPosition.target.latitude
                    targetMap["longitude"] = cameraPosition.target.longitude
                    
                    cameraPositionMap["target"] = targetMap
                    cameraPositionMap["zoom"] = cameraPosition.zoom.toDouble()
                    cameraPositionMap["tilt"] = cameraPosition.tilt.toDouble()
                    cameraPositionMap["bearing"] = cameraPosition.bearing.toDouble()
                    
                    arguments["cameraPosition"] = cameraPositionMap
                    methodChannel.invokeMethod("camera#onMove", arguments)
                }
            }
            
            override fun onCameraChangeFinish(cameraPosition: CameraPosition?) {
                methodChannel.invokeMethod("camera#onIdle", null)
            }
        })
        
        // 标记点点击事件
        aMap.setOnMarkerClickListener { marker ->
            val markerId = markersController.getMarkerId(marker)
            if (markerId != null) {
                methodChannel.invokeMethod("marker#onTap", markerId)
            }
            // 返回true表示已经处理该事件，不会显示默认的信息窗口
            false
        }
        
        // 标记点拖动事件
        aMap.setOnMarkerDragListener(object : AMap.OnMarkerDragListener {
            override fun onMarkerDragStart(marker: Marker?) {}
            
            override fun onMarkerDrag(marker: Marker?) {}
            
            override fun onMarkerDragEnd(marker: Marker?) {
                if (marker != null) {
                    val markerId = markersController.getMarkerId(marker)
                    if (markerId != null) {
                        val arguments = HashMap<String, Any>()
                        arguments["markerId"] = markerId
                        
                        val position = HashMap<String, Any>()
                        position["latitude"] = marker.position.latitude
                        position["longitude"] = marker.position.longitude
                        arguments["position"] = position
                        
                        methodChannel.invokeMethod("marker#onDragEnd", arguments)
                    }
                }
            }
        })
    }

    private fun applyCreationParams() {
        if (creationParams == null) {
            return
        }

        // 设置地图类型
        val mapType = creationParams["mapType"] as? Int
        if (mapType != null) {
            when (mapType) {
                0 -> aMap.mapType = AMap.MAP_TYPE_NORMAL // 标准地图
                1 -> aMap.mapType = AMap.MAP_TYPE_SATELLITE // 卫星地图
                2 -> aMap.mapType = AMap.MAP_TYPE_NIGHT // 夜间模式
                3 -> aMap.mapType = AMap.MAP_TYPE_NAVI // 导航模式
                4 -> aMap.mapType = AMap.MAP_TYPE_BUS // 公交模式
            }
        }

        // 显示室内地图
        val showIndoorMap = creationParams["showIndoorMap"] as? Boolean
        if (showIndoorMap != null) {
            aMap.showIndoorMap(showIndoorMap)
        }

        // 显示建筑物
        val showBuildings = creationParams["showBuildings"] as? Boolean
        if (showBuildings != null) {
            aMap.showBuildings(showBuildings)
        }

        // 显示文本标注
        val showLabels = creationParams["showLabels"] as? Boolean
        if (showLabels != null) {
            aMap.showMapText(showLabels)
        }

        // 显示交通状况
        val showTraffic = creationParams["showTraffic"] as? Boolean
        if (showTraffic != null) {
            aMap.isTrafficEnabled = showTraffic
        }

        // 手势设置
        val uiSettings = aMap.uiSettings

        // 缩放手势
        val zoomGesturesEnabled = creationParams["zoomGesturesEnabled"] as? Boolean
        if (zoomGesturesEnabled != null) {
            uiSettings.isZoomGesturesEnabled = zoomGesturesEnabled
        }

        // 滑动手势
        val scrollGesturesEnabled = creationParams["scrollGesturesEnabled"] as? Boolean
        if (scrollGesturesEnabled != null) {
            uiSettings.isScrollGesturesEnabled = scrollGesturesEnabled
        }

        // 旋转手势
        val rotateGesturesEnabled = creationParams["rotateGesturesEnabled"] as? Boolean
        if (rotateGesturesEnabled != null) {
            uiSettings.isRotateGesturesEnabled = rotateGesturesEnabled
        }

        // 倾斜手势
        val tiltGesturesEnabled = creationParams["tiltGesturesEnabled"] as? Boolean
        if (tiltGesturesEnabled != null) {
            uiSettings.isTiltGesturesEnabled = tiltGesturesEnabled
        }

        // 定位按钮
        val myLocationButtonEnabled = creationParams["myLocationButtonEnabled"] as? Boolean
        if (myLocationButtonEnabled != null) {
            uiSettings.isMyLocationButtonEnabled = myLocationButtonEnabled
        }

        // 缩放按钮
        val zoomControlsEnabled = creationParams["zoomControlsEnabled"] as? Boolean
        if (zoomControlsEnabled != null) {
            uiSettings.isZoomControlsEnabled = zoomControlsEnabled
        }

        // 指南针
        val compassEnabled = creationParams["compassEnabled"] as? Boolean
        if (compassEnabled != null) {
            uiSettings.isCompassEnabled = compassEnabled
        }

        // 比例尺
        val scaleControlsEnabled = creationParams["scaleControlsEnabled"] as? Boolean
        if (scaleControlsEnabled != null) {
            uiSettings.isScaleControlsEnabled = scaleControlsEnabled
        }

        // 我的位置
        val myLocationEnabled = creationParams["myLocationEnabled"] as? Boolean
        if (myLocationEnabled != null && myLocationEnabled) {
            setupLocationStyle()
        }

        // 初始相机位置
        val initialCameraPositionMap = creationParams["initialCameraPosition"] as? Map<String, Any>
        if (initialCameraPositionMap != null) {
            val targetMap = initialCameraPositionMap["target"] as? Map<String, Any>
            if (targetMap != null) {
                val latitude = targetMap["latitude"] as? Double
                val longitude = targetMap["longitude"] as? Double
                if (latitude != null && longitude != null) {
                    val zoom = initialCameraPositionMap["zoom"] as? Double ?: 10.0
                    val tilt = initialCameraPositionMap["tilt"] as? Double ?: 0.0
                    val bearing = initialCameraPositionMap["bearing"] as? Double ?: 0.0

                    val cameraPosition = CameraPosition(
                        LatLng(latitude, longitude),
                        zoom.toFloat(),
                        tilt.toFloat(),
                        bearing.toFloat()
                    )
                    aMap.moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition))
                }
            }
        }

        // 初始标记点
        val markers = creationParams["markers"] as? List<Map<String, Any>>
        if (markers != null) {
            markersController.addMarkers(markers)
        }
    }

    private fun setupLocationStyle() {
        val myLocationStyle = MyLocationStyle()
        // 设置定位蓝点的Style
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE)
        // 设置是否显示定位小蓝点，true表示显示，false表示不显示
        myLocationStyle.showMyLocation(true)
        // 设置定位小蓝点的图标
        // myLocationStyle.myLocationIcon(BitmapDescriptorFactory.fromAsset("images/location_marker.png"))
        // 使用默认图标避免资源问题
        myLocationStyle.myLocationIcon(BitmapDescriptorFactory.defaultMarker())
        // 设置精度圈的颜色
        // myLocationStyle.strokeColor(0xAAFFFF00)
        // 设置精度圈的宽度
        myLocationStyle.strokeWidth(1f)
        // 设置精度圈的填充颜色
        myLocationStyle.radiusFillColor(0x30FFFF00)

        // 设置定位样式
        aMap.myLocationStyle = myLocationStyle
        // 设置为true表示启动显示定位蓝点，false表示隐藏定位蓝点并不进行定位
        aMap.isMyLocationEnabled = true
    }

    override fun getView(): View {
        return mapView
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        mapView.onDestroy()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "camera#move" -> {
                val positionMap = call.argument<Map<String, Any>>("position")
                if (positionMap != null) {
                    moveCamera(positionMap, false)
                    result.success(null)
                } else {
                    result.error("INVALID_POSITION", "相机位置参数无效", null)
                }
            }
            "camera#animate" -> {
                val positionMap = call.argument<Map<String, Any>>("position")
                if (positionMap != null) {
                    val duration = call.argument<Int>("duration") ?: 500
                    moveCamera(positionMap, true, duration.toLong())
                    result.success(null)
                } else {
                    result.error("INVALID_POSITION", "相机位置参数无效", null)
                }
            }
            "map#getCurrentLocation" -> {
                val location = aMap.myLocation
                if (location != null) {
                    val locationMap = HashMap<String, Any>()
                    val latLngMap = HashMap<String, Any>()
                    latLngMap["latitude"] = location.latitude
                    latLngMap["longitude"] = location.longitude
                    locationMap["latLng"] = latLngMap
                    locationMap["accuracy"] = location.accuracy.toDouble()
                    locationMap["altitude"] = location.altitude
                    locationMap["speed"] = location.speed.toDouble()
                    locationMap["bearing"] = location.bearing.toDouble()
                    locationMap["time"] = location.time
                    result.success(locationMap)
                } else {
                    result.error("LOCATION_UNAVAILABLE", "当前位置信息不可用", null)
                }
            }
            "markers#addMarker" -> {
                val markerMap = call.argument<Map<String, Any>>("marker")
                if (markerMap != null) {
                    val markerId = markersController.addMarker(markerMap)
                    result.success(markerId)
                } else {
                    result.error("INVALID_MARKER", "标记点参数无效", null)
                }
            }
            "markers#addMarkers" -> {
                val markers = call.argument<List<Map<String, Any>>>("markers")
                if (markers != null) {
                    val markerIds = markersController.addMarkers(markers)
                    result.success(markerIds)
                } else {
                    result.error("INVALID_MARKERS", "标记点列表参数无效", null)
                }
            }
            "markers#removeMarker" -> {
                val markerId = call.argument<String>("markerId")
                if (markerId != null) {
                    markersController.removeMarker(markerId)
                    result.success(null)
                } else {
                    result.error("INVALID_MARKER_ID", "标记点ID参数无效", null)
                }
            }
            "markers#removeMarkers" -> {
                val markerIds = call.argument<List<String>>("markerIds")
                if (markerIds != null) {
                    markersController.removeMarkers(markerIds)
                    result.success(null)
                } else {
                    result.error("INVALID_MARKER_IDS", "标记点ID列表参数无效", null)
                }
            }
            "markers#clear" -> {
                markersController.clear()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun moveCamera(positionMap: Map<String, Any>, animate: Boolean, duration: Long = 300) {
        val targetMap = positionMap["target"] as? Map<String, Any>
        if (targetMap != null) {
            val latitude = targetMap["latitude"] as? Double
            val longitude = targetMap["longitude"] as? Double
            if (latitude != null && longitude != null) {
                val zoom = positionMap["zoom"] as? Double ?: 10.0
                val tilt = positionMap["tilt"] as? Double ?: 0.0
                val bearing = positionMap["bearing"] as? Double ?: 0.0

                val cameraPosition = CameraPosition(
                    LatLng(latitude, longitude),
                    zoom.toFloat(),
                    tilt.toFloat(),
                    bearing.toFloat()
                )

                if (animate) {
                    aMap.animateCamera(
                        CameraUpdateFactory.newCameraPosition(cameraPosition),
                        duration,
                        null
                    )
                } else {
                    aMap.moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition))
                }
            }
        }
    }
}

    class MarkersController(private val aMap: AMap, private val context: Context) {

    private val markers = HashMap<String, Marker>()
    private val markerIds = HashMap<Marker, String>() // 用于反向查找markerId

    fun addMarker(markerMap: Map<String, Any>): String {
        val markerId = markerMap["markerId"] as String
        val positionMap = markerMap["position"] as Map<String, Any>
        val latitude = positionMap["latitude"] as Double
        val longitude = positionMap["longitude"] as Double

        val markerOptions = MarkerOptions()
            .position(LatLng(latitude, longitude))

        // 设置标题
        val title = markerMap["title"] as? String
        if (title != null) {
            markerOptions.title(title)
        }

        // 设置片段
        val snippet = markerMap["snippet"] as? String
        if (snippet != null) {
            markerOptions.snippet(snippet)
        }

        // 设置可拖动性
        val draggable = markerMap["draggable"] as? Boolean
        if (draggable != null) {
            markerOptions.draggable(draggable)
        }

        // 设置是否平贴地图
        val flat = markerMap["flat"] as? Boolean
        if (flat != null) {
            markerOptions.setFlat(flat)
        }

        // 设置锚点
        val anchor = markerMap["anchor"] as? Map<String, Any>
        if (anchor != null) {
            val x = anchor["x"] as? Double ?: 0.5
            val y = anchor["y"] as? Double ?: 1.0
            markerOptions.anchor(x.toFloat(), y.toFloat())
        }

        // 设置图标
        val icon = markerMap["icon"] as? String
        if (icon != null) {
            // 假设图标是资源ID
            val resourceId = context.resources.getIdentifier(
                icon,
                "drawable",
                context.packageName
            )
            if (resourceId != 0) {
                markerOptions.icon(BitmapDescriptorFactory.fromResource(resourceId))
            }
        }

        // 添加标记点
        val marker = aMap.addMarker(markerOptions)
        markers[markerId] = marker
        markerIds[marker] = markerId // 添加反向映射

        return markerId
    }
    
    // 通过Marker对象获取markerId
    fun getMarkerId(marker: Marker): String? {
        return markerIds[marker]
    }

    fun addMarkers(markersList: List<Map<String, Any>>): List<String> {
        val markerIds = ArrayList<String>()
        for (markerMap in markersList) {
            val markerId = addMarker(markerMap)
            markerIds.add(markerId)
        }
        return markerIds
    }

    fun removeMarker(markerId: String) {
        val marker = markers[markerId]
        // marker?.remove()
        marker?.let {
            it.remove()
            markerIds.remove(it) // 移除反向映射
        }
        markers.remove(markerId)
    }
    fun removeMarkers(markerIdsList: List<String>) {
        for (markerId in markerIdsList) {
            removeMarker(markerId)
        }
    }

    fun clear() {
        aMap.clear()
        markers.clear()
        markerIds.clear()
    }
} 