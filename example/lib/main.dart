import 'dart:convert'; // 导入 jsonDecode 函数
import 'package:flutter/material.dart';
import 'package:alissda/alissda.dart'; // 引入你的插件
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _evaluationResult = '暂无结果';
  bool _isEvaluating = false;
  bool _issetAuthInfo = false;

  @override
  void initState() {
    super.initState();
    _initializePlugin();
    _listenToResults();
  }

  // 设置授权信息
  Future<void> _setAuthInfo() async {
    try {

      await AlissdaPlugin.setAuthInfo("680a1357fe25d6b2ff14c6c447b002bd", 1745490775); // 设置 warrantId
      _issetAuthInfo = true;
      print("授权信息设置成功");
    } catch (e) {
      print("授权信息设置失败: $e");
    }
  }

  // 监听评测结果
  void _listenToResults() {
    AlissdaPlugin.startListeningToResults().listen((result) {
      setState(() {
        print('----------------评测结果: $result');
        if (result.startsWith('onResult: ')) {
          // 移除 "onResult: " 部分
          String jsonString = result.substring('onResult: '.length);

          // 将字符串解析为 JSON 对象
          try {
            Map<String, dynamic> json = jsonDecode(jsonString);
            print("Parsed JSON: $json['result']['overall']");
            if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
              var result = json['result'] as Map<String, dynamic>;
              if (result.containsKey('overall')) {
                var overall = result['overall'];
                _evaluationResult = "$overall";
              } else {
                print("Key 'overall' not found in 'result'");
              }
            } else {
              print("Key 'result' not found or is not a map");
            }
          } catch (e) {
            print("Failed to parse JSON: $e");
          }
        } else {
          print("Input does not start with 'onResult: '");
        }
      });
    }, onError: (error) {
      setState(() {
        _evaluationResult = '评测错误: $error';
      });
    });
  }

  // 初始化插件
  Future<void> _initializePlugin() async {
    try {
      await AlissdaPlugin.initialize('a0007jg', 'yiFUXdFBbBRMiIIUXqjNebwgjwnteOZj');
      print('插件初始化成功');
    } catch (e) {
      print('插件初始化失败: $e');
    }
  }

  // 检查并请求录音权限
  Future<bool> _checkAndRequestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      return true; // 权限已授予
    } else {
      // 请求权限
      var result = await Permission.microphone.request();
      return result.isGranted; // 返回权限是否授予
    }
  }

  // 开始评测
  Future<void> _startEvaluation() async {
    // 检查录音权限
    bool hasPermission = await _checkAndRequestMicrophonePermission();
    if (!hasPermission) {
      // 如果权限未授予，提示用户
      setState(() {
        _evaluationResult = '录音权限未授予，无法开始评测';
      });
      return;
    }

    // 使用 Future.microtask 确保 setState 在主线程中执行
    Future.microtask(() {
      setState(() {
        _evaluationResult = '正在评测...';
        _isEvaluating = true;
      });
    });

    try {
      await AlissdaPlugin.startEvaluation('12000666', 'hello world!', "en.pred.score");
    } catch (e) {
      print('开始评测失败: $e');
      setState(() {
        _evaluationResult = '评测失败: $e';
        _isEvaluating = false;
      });
    }
  }

  // 停止评测
  Future<void> _stopEvaluation() async {
    try {
      await AlissdaPlugin.stopEvaluation();
      // 使用 Future.microtask 确保 setState 在主线程中执行
      Future.microtask(() {
        setState(() {
          _evaluationResult = '评测已停止';
          _isEvaluating = false;
        });
      });
    } catch (e) {
      print('停止评测失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alissda Plugin Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                _evaluationResult,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isEvaluating ? null : _startEvaluation,
                child: const Text('开始评测'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isEvaluating ? _stopEvaluation : null,
                child: const Text('停止评测'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _issetAuthInfo ? null: _setAuthInfo,
                child: const Text('设置授权信息'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}