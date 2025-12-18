# 阿里语音评测插件 (Alissda) 使用说明

阿里语音评测插件提供了一套完整的语音评测功能接口，支持语音识别、发音评估等功能。

## 目录

- [安装](#安装)
- [初始化](#初始化)
- [设置授权信息](#设置授权信息)
- [开始评测](#开始评测)
- [停止评测](#停止评测)
- [取消评测](#取消评测)
- [安全删除评测引擎](#安全删除评测引擎)
- [清除所有录音记录](#清除所有录音记录)
- [事件监听](#事件监听)

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  alissda: ^版本号
```

然后执行：

```bash
flutter pub get
```

在代码中导入：

```dart
import 'package:alissda/alissda.dart';
```

## 初始化

在使用插件之前，必须先进行初始化：

```dart
await AlissdaPlugin.init(
  appKey: 'your_app_key',
  secretKey: 'your_secret_key',
  userId: 'your_user_id',
);
```

## 设置授权信息

在初始化之后，需要设置授权信息：

```dart
await AlissdaPlugin.setAuthInfo(
  warrantId: 'your_warrant_id',
  authTimeout: 7200, // 可选，默认为7200秒
);
```

## 开始评测

配置并启动语音评测：

```dart
await AlissdaPlugin.start(
  refText: 'Hello world', // 评测参考文本
  coreType: 'en.sent.score', // 评测核心类型
  outputPhones: 1, // 可选，默认为1
  typeThres: 2, // 可选，默认为2
  checkPhones: true, // 可选，默认为true
);
```

## 停止评测

正常停止当前正在进行的评测：

```dart
await AlissdaPlugin.stop();
```

## 取消评测

取消当前正在进行的评测：

```dart
await AlissdaPlugin.cancel();
```

## 安全删除评测引擎

安全删除评测引擎：

```dart
await AlissdaPlugin.deleteSafe();
```

## 清除所有录音记录

清除所有录音记录：ios 独有

```dart
await AlissdaPlugin.clearAllRecord();
```

## 事件监听

通过 [messageStream](file:///Users/mac/developments/alissda/lib/alissda.dart#L81-L82) 可以监听来自插件的消息和评测结果：

```dart
AlissdaPlugin.messageStream.listen((message) {
  // 处理接收到的消息
  print('Received message: $message');
});
```