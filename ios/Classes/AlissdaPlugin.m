#import "AlissdaPlugin.h"
#import <SingSound/SSOralEvaluatingConfig.h> // Import the SingSound framework
#import <SingSound/SSOralEvaluatingManager.h> // Import the SingSound framework
#import <SingSound/SSOralEvaluatingManagerConfig.h> // Import the SingSound framework

@interface AlissdaPlugin() <SSOralEvaluatingManagerDelegate>
@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) FlutterEventChannel *eventChannel;
@property (nonatomic, strong) FlutterEventSink eventSink;
@end

@implementation AlissdaPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  AlissdaPlugin* instance = [[AlissdaPlugin alloc] init];
  instance.methodChannel = [FlutterMethodChannel
      methodChannelWithName:@"alissda"
            binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:instance.methodChannel];

  instance.eventChannel = [FlutterEventChannel
      eventChannelWithName:@"alissda/events"
           binaryMessenger:[registrar messenger]];
  [instance.eventChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initialize" isEqualToString:call.method]) {
    NSString *appKey = call.arguments[@"appKey"];
    NSString *secretKey = call.arguments[@"secretKey"];
    NSString *userId = call.arguments[@"userId"];
    [self initializeEngineWithAppKey:appKey secretKey:secretKey userId:userId];
    result(@"initialized");
  } else if ([@"startEvaluation" isEqualToString:call.method]) {
    NSString *userId = call.arguments[@"userId"];
    NSString *refText = call.arguments[@"refText"];
    NSString *coreType = call.arguments[@"coreType"];
    NSNumber *outputPhonesNum = call.arguments[@"outputPhones"];
    NSNumber *typeThresNum = call.arguments[@"typeThres"];
    NSNumber *checkPhonesNum = call.arguments[@"checkPhones"];

    [self startEvaluationWithUserId:userId
                            refText:refText
                           coreType:coreType
                        checkPhones:[checkPhonesNum boolValue]
                          typeThres:[typeThresNum integerValue]
                       outputPhones:[outputPhonesNum integerValue]];
//     [self startEvaluationWithUserId:userId refText:refText coreType:coreType ];
    result(@"started");
  } else if ([@"stopEvaluation" isEqualToString:call.method]) {
    [self stopEvaluation];
    result(@"stopped");
  } else if ([@"setAuthInfo" isEqualToString:call.method]) {
    NSString *warrantId = call.arguments[@"warrantId"];
    NSNumber *authTimeout = call.arguments[@"authTimeout"];
    NSString *authTimeoutString = [authTimeout stringValue];
    [self setAuthInfoWithWarrantId:warrantId AuthTimeout:authTimeoutString];
    result(@"authInfoSet");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)initializeEngineWithAppKey:(NSString *)appKey secretKey:(NSString *)secretKey userId:(NSString *)userId  {
  SSOralEvaluatingManagerConfig *managerConfig = [[SSOralEvaluatingManagerConfig alloc] init];
  managerConfig.appKey = appKey;
  managerConfig.secretKey = secretKey;
  managerConfig.logLevel = @4;
  managerConfig.isOutputLog = YES;
  managerConfig.allowDynamicService = YES;

  [SSOralEvaluatingManager registerEvaluatingManagerConfig:managerConfig];
  NSLog(@"这是一条来自 Flutter 插件的日志---- ");
  NSLog(userId);

  [[SSOralEvaluatingManager shareManager] registerEvaluatingType:OralEvaluatingTypeLine userId:userId];

  [SSOralEvaluatingManager shareManager].delegate = self;
}

- (void)startEvaluationWithUserId:(NSString *)userId refText:(NSString *)refText coreType:(NSString *)coreType
    checkPhones:(BOOL)checkPhones
    typeThres:(NSInteger)typeThres
    outputPhones:(NSInteger)outputPhones
     {
    SSOralEvaluatingConfig *config = [[SSOralEvaluatingConfig alloc] init];
    config.oralContent = refText;
    config.userId = userId;
    config.audioUrlScheme = @"https";
    config.outputPhones = outputPhones; //1;
    config.checkPhones = checkPhones; //true;
    config.typeThres = typeThres;//1;

    if ([coreType isEqualToString:@"en.pred.score"]) {
        config.oralType = OralTypeParagraph;
    } else if ([coreType isEqualToString:@"en.word.score"]) {
        config.oralType = OralTypeWord;
    } else if ([coreType isEqualToString:@"en.sent.score"]) {
        config.oralType = OralTypeSentence;
    } else if ([coreType isEqualToString:@"en.choc.score"]) {
        config.oralType = OralTypeChoose;
    } else if ([coreType isEqualToString:@"en.pqan.score"]) {
        config.oralType = OralTypeEssayQuestion;
    } else if ([coreType isEqualToString:@"en.pict.score"]) {
        config.oralType = OralTypePicture;
    } else if ([coreType isEqualToString:@"cn.word.score"]) {
        config.oralType = OralTypeChineseWord;
    } else if ([coreType isEqualToString:@"cn.sent.score"]) {
        config.oralType = OralTypeChineseSentence;
    } else if ([coreType isEqualToString:@"cn.pcha.score"]) {
        config.oralType = OralTypeChinesePcha;
    } else if ([coreType isEqualToString:@"cn.pred.score"]) {
        config.oralType = OralTypeChinesePred;
    } else if ([coreType isEqualToString:@"en.pcha.score"]) {
        config.oralType = OralTypeEnglishPcha;
    } else if ([coreType isEqualToString:@"en.alpha.score"]) {
        config.oralType = OralTypeAlpha;
    } else if ([coreType isEqualToString:@"en.sent.rec"]) {
        config.oralType = OralTypeRec;
    } else if ([coreType isEqualToString:@"en.pche.score"]) {
        config.oralType = OralTypePche;
    } else if ([coreType isEqualToString:@"en.retell.score"]) {
        config.oralType = OralTypeRetell;
    } else if ([coreType isEqualToString:@"en.word_kid.score"]) {
        config.oralType = OralTypeKidWord;
    } else if ([coreType isEqualToString:@"en.sent_kid.score"]) {
        config.oralType = OralTypeKidSent;
    } else if ([coreType isEqualToString:@"en.mpd.score"]) {
        config.oralType = OralTypeMpd;
    } else if ([coreType isEqualToString:@"cn.poet.score"]) {
        config.oralType = OralTypePoet;
    } else if ([coreType isEqualToString:@"cn.sent.rec"]) {
        config.oralType = OralTypeCnRec;
    } else if ([coreType isEqualToString:@"en.sent.rec_en"]) {
        config.oralType = OralTypeEnRec;
    } else {
        // 默认为句子类型
        config.oralType = OralTypeSentence;
    }


  [[SSOralEvaluatingManager shareManager] startEvaluateOralWithConfig:config];
}

- (void)stopEvaluation {
  [[SSOralEvaluatingManager shareManager] stopEvaluate];
}

- (void)cancelEvaluation {
  [[SSOralEvaluatingManager shareManager] cancelEvaluate];
}

- (void)deleteSafeEvaluation {
  [[SSOralEvaluatingManager shareManager] engineDealloc];
}

- (void)clearAllRecordEvaluation {
  [[SSOralEvaluatingManager shareManager] clearAllRecord];
}

- (void)setAuthInfoWithWarrantId:(NSString *)warrantId AuthTimeout:(NSString *) authTimeout {
  [[SSOralEvaluatingManager shareManager] setAuthInfoWithWarrantId:warrantId AuthTimeout:authTimeout];
}

#pragma mark - SSOralEvaluatingManagerDelegate

- (void)oralEvaluatingDidEndWithResult:(NSString *)result isLast:(BOOL)isLast {
  if (self.eventSink) {
      NSError *error;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
      NSString *aaa;
      if (!jsonData) {
          NSLog(@"Error converting to JSON: %@", error);
          aaa = @'Error converting to JSON';
      }else{
          aaa = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      }

    self.eventSink([NSString stringWithFormat:@"onResult: %@", aaa]);
  }
}

- (void)oralEvaluatingDidEndError:(NSError *)error {
  if (self.eventSink) {
    self.eventSink([FlutterError errorWithCode:@"onERROR"
                                       message:error.localizedDescription
                                       details:nil]);
  }
}

- (void)oralEvaluatingDidVADFrontTimeOut {
  if (self.eventSink) {
    self.eventSink(@"frontVadTimeout");
  }
}

- (void)oralEvaluatingDidVADBackTimeOut {
  if (self.eventSink) {
    self.eventSink(@"backVadTimeout");
  }
}

#pragma mark - FlutterStreamHandler

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  self.eventSink = events;
  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  self.eventSink = nil;
  return nil;
}

@end

