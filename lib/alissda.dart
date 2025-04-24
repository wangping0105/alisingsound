import 'package:flutter/services.dart';

class AlissdaPlugin {
  static const MethodChannel _channel = MethodChannel('alissda');
  static const EventChannel _eventChannel = EventChannel('alissda/events');

  // 初始化引擎
  static Future<void> initialize(String appKey, String secretKey) async {
    await _channel.invokeMethod('initialize', {
      'appKey': appKey,
      'secretKey': secretKey,
    });
  }

  // 开始评测
  static Future<void> startEvaluation(String userId, String refText, String coreType) async {
    await _channel.invokeMethod('startEvaluation', {
      'userId': userId,
      'refText': refText,
      'coreType': coreType
    });
  }

  // 停止评测
  static Future<void> stopEvaluation() async {
    await _channel.invokeMethod('stopEvaluation');
  }

  // 设置授权信息
  static Future<void> setAuthInfo(String warrantId, int authTimeout) async {
    await _channel.invokeMethod('setAuthInfo', {
      'warrantId': warrantId,
      'authTimeout': authTimeout,
    });
  }

  // 监听评测结果
  static Stream<dynamic> startListeningToResults() {
    return _eventChannel.receiveBroadcastStream();
  }
}
