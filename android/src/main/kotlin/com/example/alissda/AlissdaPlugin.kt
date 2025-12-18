package com.example.alissda

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import org.json.JSONObject
import com.xs.SingEngine
//import com.xs.record.*
//import com.xs.impl.*
import com.xs.impl.AudioErrorCallback
//import com.xs.res.*
//import com.xs.utils.*
//import com.core.entity.*
//import com.constraint.*
import com.constraint.AudioTypeEnum
import com.constraint.ResultBody
import com.constraint.CoreProvideTypeEnum
import com.xs.impl.ResultListener

class AlissdaPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

  companion object {
    init {
      System.loadLibrary("ssound") // 加载 libssound.so
    }
  }

  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private var eventSink: EventChannel.EventSink? = null
  private var activity: Activity? = null
  private var context: Context? = null
  private var mEngine: SingEngine? = null
  private val mainHandler = Handler(Looper.getMainLooper()) // 用于切换到主线程

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    methodChannel = MethodChannel(binding.binaryMessenger, "alissda")
    methodChannel.setMethodCallHandler(this)
    eventChannel = EventChannel(binding.binaryMessenger, "alissda/events")
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventSink = null
      }
    })
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "initialize" -> {
        val appKey = call.argument<String>("appKey").orEmpty()
        val secretKey = call.argument<String>("secretKey").orEmpty()
        initEngine(appKey, secretKey)
        result.success("initialized")
      }
      "startEvaluation" -> {
        val userId = call.argument<String>("userId") ?: ""
        val refText = call.argument<String>("refText") ?: ""
        val coreType = call.argument<String>("coreType") ?: ""
        val outputPhones = call.argument<Int>("outputPhones") ?: 0
        val typeThres = call.argument<Int>("typeThres") ?: 0
        val checkPhones = call.argument<Boolean>("checkPhones") ?: false
        startEvaluation(userId, refText, coreType, outputPhones, checkPhones, typeThres)
        result.success("started")
      }
      "stopEvaluation" -> {
        stopEvaluation()
        result.success("stopped")
      }
      "setAuthInfo" -> {
        val warrantId = call.argument<String>("warrantId").orEmpty()
        val authTimeout = call.argument<Int>("authTimeout") ?: 0

        setAuthInfo(warrantId, authTimeout.toLong())
        result.success("authInfoSet")
      }
      else -> result.notImplemented()
    }
  }

  private val mResultListener = object : ResultListener {
    override fun onBegin() {
      sendEvent("onBegin")
    }

    override fun onResult(result: JSONObject?) {
      println("--------ddd--------------")
      println(result)
      println("--------ddd--------------")

      if (result != null) {
        sendEvent("onResult: $result")
      } else {
        sendError("NULL_RESULT", "resultBody is null", null)
      }
    }

    override fun onEnd(resultBody: ResultBody?) {
      if (resultBody != null) {
        val json = JSONObject().apply {
          put("code", resultBody.code) // 举例字段
          put("json", resultBody.json)
        }
        sendEvent("onEnd: $json")
      } else {
        sendError("NULL_RESULT", "resultBody is null", null)
      }
    }

    override fun onUpdateVolume(volume: Int) {
      sendEvent("volume: $volume")
    }

    override fun onFrontVadTimeOut() {
      sendEvent("frontVadTimeout")
    }

    override fun onBackVadTimeOut() {
      sendEvent("backVadTimeout")
    }

    override fun onRecordingBuffer(data: ByteArray?, size: Int) {
      // 一般可以忽略或者你可以上报录音数据
    }

    override fun onRecordLengthOut() {
      sendEvent("recordLengthOut")
    }

    override fun onReady() {
      sendEvent("onReady")
    }

    override fun onPlayCompeleted() {
      sendEvent("onPlayCompleted")
    }

    override fun onRecordStop() {
      sendEvent("onRecordStop")
    }
  }

  private val mAudioErrorCallback = AudioErrorCallback { errorCode ->
    sendError("AUDIO_ERROR", "Audio initialization failed", errorCode)
  }

  private fun initEngine(appKey: String, secretKey: String) {
    Thread {
      try {
        activity?.let { act ->
          mEngine = SingEngine.newInstance(act).apply {
            setListener(mResultListener)
            setAudioErrorCallback(mAudioErrorCallback)
            setAudioType(AudioTypeEnum.WAV)
            setServerType(CoreProvideTypeEnum.CLOUD)
            setLogLevel(4)
            disableVolume()
            setOpenVad(false, null)
            val cfgInit = buildInitJson(appKey, secretKey)
            setNewCfg(cfgInit)
            createEngine()
          }
        }
      } catch (e: Exception) {
        e.printStackTrace()
        sendError("INIT_ERROR", e.localizedMessage ?: "Unknown error", null)
      }
    }.start()
  }

  private fun startEvaluation(userId: String, refText: String, coreType: String, outputPhones: Int, checkPhones: Boolean, typeThres: Int) {
    try {
      val request = JSONObject().apply {
        put("coreType", coreType)
        put("refText", refText)
        put("rank", 100)
        put("audioUrlScheme", "https")
        put("outputPhones", outputPhones)
        put("checkPhones", checkPhones)
        put("typeThres", typeThres)
      }
      mEngine?.apply {
        setStartCfg(buildStartJson(userId, request))
        start()
      }
    } catch (e: Exception) {
      e.printStackTrace()
      sendError("EVAL_START_ERROR", e.localizedMessage ?: "Unknown error", null)
    }
  }

  private fun stopEvaluation() {
    try {
      mEngine?.stop()
    } catch (e: Exception) {
      e.printStackTrace()
      sendError("EVAL_STOP_ERROR", e.localizedMessage ?: "Unknown error", null)
    }
  }

  private fun cancelEvaluation() {
    try {
      mEngine?.cancel()
    } catch (e: Exception) {
      e.printStackTrace()
      sendError("EVAL_cancel_ERROR", e.localizedMessage ?: "Unknown error", null)
    }
  }

  private fun deleteEvaluation() {
    try {
      mEngine?.delete()
    } catch (e: Exception) {
      e.printStackTrace()
      sendError("EVAL_delete_ERROR", e.localizedMessage ?: "Unknown error", null)
    }
  }
  private fun deleteSafeEvaluation() {
    try {
      mEngine?.deleteSafe()
    } catch (e: Exception) {
      e.printStackTrace()
      sendError("EVAL_deleteSafe_ERROR", e.localizedMessage ?: "Unknown error", null)
    }
  }

  private fun clearAllRecordEvaluation(): Boolean {
    try {
      // 调用 SingEngine 的 clearWavWithDefaultPath 方法来清理音频文件
      return true
    } catch (e: Exception) {
      e.printStackTrace()
      sendError("EVAL_clearWavWithDefaultPath_ERROR", e.localizedMessage ?: "Unknown error", null)
      return false
    }
  }

  private fun setAuthInfo(warrantId: String, authTimeout: Long) {
    try {
      mEngine?.setAuthInfo(warrantId, authTimeout)
    } catch (e: Exception) {
      e.printStackTrace()
      sendError("EVAL_setAuthInfo_ERROR", e.localizedMessage ?: "Unknown error", null)
    }
  }

  // 发送事件到 Flutter（确保在主线程中执行）
  private fun sendEvent(event: String) {
    mainHandler.post {
      eventSink?.success(event)
    }
  }

  // 发送错误到 Flutter（确保在主线程中执行）
  private fun sendError(code: String, message: String, details: Any?) {
    mainHandler.post {
      eventSink?.error(code, message, details)
    }
  }
}