import 'package:flutter/services.dart';

/// 阿里语音评测插件 (Alissda) 的主接口类
///
/// 提供语音评测相关的所有功能接口，包括初始化、开始/停止评测、
/// 设置授权信息等操作。
class AlissdaPlugin {
  static const MethodChannel _channel = MethodChannel('alissda');
  static const EventChannel _eventChannel = EventChannel('alissda/events');
  static String _appKey = '';
  static String _secretKey = '';
  static String _userId = '';

  /// 初始化语音评测引擎
  ///
  /// 必须在使用其他功能前调用此方法进行初始化
  ///
  /// [appKey] 应用标识
  /// [secretKey] 应用密钥
  /// [userId] 用户标识
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

  /// 开始语音评测
  ///
  /// [refText] 评测参考文本
  /// [coreType] 评测核心类型
  /// [outputPhones] 是否输出音素信息，默认为 1 (是)
  /// [typeThres] 类型阈值，默认为 2
  /// [checkPhones] 是否检查音素，默认为 true
  static Future<void> start({
    required String refText,
    required String coreType,
    int outputPhones = 1,
    int typeThres = 2,
    bool checkPhones = true,
  }) async {
    await _channel.invokeMethod('startEvaluation', {
      'userId': _userId,
      'refText': refText,
      'coreType': coreType,
      'outputPhones': outputPhones,
      'typeThres': typeThres,
      'checkPhones': checkPhones,
    });
  }

  /// 停止当前正在进行的语音评测
  static Future<void> stop() async {
    await _channel.invokeMethod('stopEvaluation');
  }

  /// 取消当前正在进行的语音评测
  static Future<void> cancel() async {
    await _channel.invokeMethod('cancelEvaluation');
  }

  /// 安全删除评测引擎
  static Future<void> deleteSafe() async {
    await _channel.invokeMethod('deleteSafeEvaluation');
  }

  /// 清除所有录音记录
  static Future<bool> clearAllRecord() async {
    final bool result = await _channel.invokeMethod('clearAllRecordEvaluation');
    return result;
  }

  /// 设置授权信息
  /// [warrantId] 授权ID
  /// [authTimeout] 授权超时时间(秒)，默认为 7200 秒(2小时)
  static Future<void> setAuthInfo({
    required String warrantId,
    int authTimeout = 7200,
  }) async {
    await _channel.invokeMethod('setAuthInfo', {
      'warrantId': warrantId,
      'authTimeout': authTimeout,
    });
  }

  /// 获取消息事件流
  ///
  /// 返回包含评测结果和其他事件通知的流
  static Stream<dynamic> get messageStream =>
      _eventChannel.receiveBroadcastStream();
}