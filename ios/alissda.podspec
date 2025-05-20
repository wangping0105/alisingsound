#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint alissda.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'alissda'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }

#   s.vendored_frameworks = 'Frameworks/SingSound.framework'
#   s.preserve_paths = 'Frameworks/SingSound.framework'

  # 添加 SingSoundSDK 依赖
    s.dependency 'SingSoundSDK'

    # 指定源
    s.source = {
      :git => 'https://pt.singsound.com:10081/singsound-public/SingSoundSDKCocoaPodRepo.git'
    }

    # 指定源
    s.source = {
      :git => 'https://github.com/CocoaPods/Specs.git'
    }

    # 如果需要手动添加源
    s.prepare_command = <<-CMD
      if ! pod repo list | grep -q "SingSoundSDKCocoaPodRepo"; then
        pod repo add SingSoundSDKCocoaPodRepo https://pt.singsound.com:10081/singsound-public/SingSoundSDKCocoaPodRepo.git
      fi
    CMD
end
