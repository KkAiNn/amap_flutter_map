package com.example.amap_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.amap.api.maps.MapsInitializer
import com.amap.api.maps.model.MyLocationStyle

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.platform.PlatformViewRegistry

/** AmapFlutterPlugin */
class AmapFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private var context: Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "amap_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    
    // 注册PlatformView工厂
    val registry = flutterPluginBinding.platformViewRegistry
    registry.registerViewFactory(
      "plugins.flutter.io/amap",
      AmapViewFactory(flutterPluginBinding.binaryMessenger, this)
    )
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "setApiKey" -> {
        val androidKey = call.argument<String>("androidKey")
        if (androidKey == null) {
          result.error("INVALID_ARGUMENT", "androidKey不能为空", null)
          return
        }
        // 设置高德地图API Key
        MapsInitializer.setApiKey(androidKey)
        result.success(true)
      }
      "updatePrivacyShow" -> {
        val hasContains = call.argument<Boolean>("hasContains") ?: false
        val hasShow = call.argument<Boolean>("hasShow") ?: false
        // 更新隐私政策展示状态
        MapsInitializer.updatePrivacyShow(context, hasContains, hasShow)
        result.success(true)
      }
      "updatePrivacyAgree" -> {
        val hasAgree = call.argument<Boolean>("hasAgree") ?: false
        // 更新隐私政策同意状态
        MapsInitializer.updatePrivacyAgree(context, hasAgree)
        result.success(true)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}

class AmapViewFactory(
  private val messenger: io.flutter.plugin.common.BinaryMessenger,
  private val plugin: AmapFlutterPlugin
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    val creationParams = args as? Map<String, Any>
    return AmapPlatformView(context, viewId, creationParams, messenger, plugin)
  }
}
