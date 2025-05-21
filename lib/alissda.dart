import 'package:flutter/services.dart';

class AlissdaPlugin {
  static const MethodChannel _channel = MethodChannel('alissda');
  static const EventChannel _eventChannel = EventChannel('alissda/events');
  static String _appKey = '';
  static String _secretKey = '';
  static String _userId = '';
  // 初始化引擎
  static Future<void> init({
    required String appKey,
    required String secretKey,
    required String userId,
  }) async {
    _userId = userId;
    _secretKey = secretKey;
    _appKey = appKey;
    await _channel.invokeMethod('initialize', {
      'appKey': appKey,
      'secretKey': secretKey,
      'userId': userId,
    });
  }

  // 开始评测
  static Future<void> start({
    required String refText,
    required String coreType,
  }) async {
    await _channel.invokeMethod('startEvaluation', {
      'userId': _userId,
      'refText': refText,
      'coreType': coreType,
    });
  }

  // 停止评测
  static Future<void> stop() async {
    await _channel.invokeMethod('stopEvaluation');
  }

  // 设置授权信息
  static Future<void> setAuthInfo({
    required String warrantId,
    int authTimeout = 7200,
  }) async {
    await _channel.invokeMethod('setAuthInfo', {
      'warrantId': warrantId,
      'authTimeout': authTimeout,
    });
  }

  static Stream<dynamic> get messageStream =>
      _eventChannel.receiveBroadcastStream();
}