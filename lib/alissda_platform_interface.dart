import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'alissda_method_channel.dart';

abstract class AlissdaPlatform extends PlatformInterface {
  /// Constructs a AlissdaPlatform.
  AlissdaPlatform() : super(token: _token);

  static final Object _token = Object();

  static AlissdaPlatform _instance = MethodChannelAlissda();

  /// The default instance of [AlissdaPlatform] to use.
  ///
  /// Defaults to [MethodChannelAlissda].
  static AlissdaPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AlissdaPlatform] when
  /// they register themselves.
  static set instance(AlissdaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
