import 'package:flutter_test/flutter_test.dart';
import 'package:alissda/alissda.dart';
import 'package:alissda/alissda_platform_interface.dart';
import 'package:alissda/alissda_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAlissdaPlatform
    with MockPlatformInterfaceMixin
    implements AlissdaPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AlissdaPlatform initialPlatform = AlissdaPlatform.instance;

  test('$MethodChannelAlissda is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAlissda>());
  });

  test('getPlatformVersion', () async {
    Alissda alissdaPlugin = Alissda();
    MockAlissdaPlatform fakePlatform = MockAlissdaPlatform();
    AlissdaPlatform.instance = fakePlatform;

    expect(await alissdaPlugin.getPlatformVersion(), '42');
  });
}
