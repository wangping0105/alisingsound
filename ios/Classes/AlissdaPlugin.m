#import "AlissdaPlugin.h"
#import <SingSound/SSOralEvaluatingConfig.h> // Import the SingSound framework
#import <SingSound/SSOralEvaluatingManager.h> // Import the SingSound framework
#import <SingSound/SSOralEvaluatingManagerConfig.h> // Import the SingSound framework

@implementation AlissdaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:@"alissda"
                                   binaryMessenger:[registrar messenger]];
  FlutterEventChannel* eventChannel = [FlutterEventChannel
                                      eventChannelWithName:@"alissda/events"
                                      binaryMessenger:[registrar messenger]];
  AlissdaPlugin* instance = [[AlissdaPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [eventChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initialize" isEqualToString:call.method]) {
    NSDictionary* arguments = call.arguments;
    NSString* appKey = arguments[@"appKey"];
    NSString* secretKey = arguments[@"secretKey"];
    [self initializeWithAppKey:appKey secretKey:secretKey];
    result(nil);
  } else if ([@"startEvaluation" isEqualToString:call.method]) {
    NSDictionary* arguments = call.arguments;
    NSString* userId = arguments[@"userId"];
    NSString* refText = arguments[@"refText"];
    [self startEvaluationWithUserId:userId refText:refText];
    result(nil);
  } else if ([@"stopEvaluation" isEqualToString:call.method]) {
    [self stopEvaluation];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

// 初始化
- (void)initializeWithAppKey:(NSString*)appKey secretKey:(NSString*)secretKey {
  SSOralEvaluatingManagerConfig *config = [[SSOralEvaluatingManagerConfig alloc] init];
  config.appKey = appKey;
  config.secretKey = secretKey;
  [SSOralEvaluatingManager registerEvaluatingManagerConfig:config];
}

// 开始评测
- (void)startEvaluationWithUserId:(NSString*)userId refText:(NSString*)refText {
  SSOralEvaluatingConfig* config = [[SSOralEvaluatingConfig alloc] init];
  config.oralContent = refText;
  config.oralType = OralTypeWord;
  [[SSOralEvaluatingManager shareManager] startEvaluateOralWithConfig:config];
}

// 停止评测
- (void)stopEvaluation {
  [[SSOralEvaluatingManager shareManager] stopEvaluate];
}
@end
