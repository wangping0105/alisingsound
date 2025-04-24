//
//  SSOralEvaluatingManager.h
//  singSoundDemo
//
//  Created by sing on 16/11/18.
//  Copyright © 2016年 an. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSOralEvaluatingConfig.h"
#import "SSOralEvaluatingManagerConfig.h"

@protocol SSOralEvaluatingManagerDelegate;

typedef NS_ENUM(NSInteger, OralEvaluatingType) {
    OralEvaluatingTypeOffLine   = 1,     //离线
    OralEvaluatingTypeLine      = 2,     //在线
    OralEvaluatingTypeMixed     = 3,    //混合模式
};

@interface SSOralEvaluatingManager : NSObject

@property (nonatomic, weak) id<SSOralEvaluatingManagerDelegate> delegate;

+ (instancetype)shareManager;

/**
 返回版本号

 @return 版本号
 */
+ (NSString *)version;

/**
 注册初始化参数

 @param config 初始化参数
 */
+ (void)registerEvaluatingManagerConfig:(SSOralEvaluatingManagerConfig *)config;


///  注册全局评测模式
/// @param type 评测模式
/// @param userId userId（必传）
- (void)registerEvaluatingType:(OralEvaluatingType)type userId:(NSString *)userId;

/**
 注册全局评测模式

 @param type 评测模式
 */
- (void)registerEvaluatingType:(OralEvaluatingType)type __attribute__((deprecated("建议使用 registerEvaluatingType:(OralEvaluatingType)type userId:(NSString *)userId")));


/// 注册全局评测模式和初始化参数
/// @param config 初始化参数
/// @param type 评测模式
/// @param userId userId（必传）
-(void)registerWithConfig:(SSOralEvaluatingManagerConfig *)config type:(OralEvaluatingType)type userId:(NSString *)userId;

/// 注册全局评测模式和初始化参数
/// @param config 初始化参数
/// @param type 评测模式
-(void)registerWithConfig:(SSOralEvaluatingManagerConfig *)config type:(OralEvaluatingType)type __attribute__((deprecated("建议使用 registerWithConfig:(SSOralEvaluatingManagerConfig *)config type:(OralEvaluatingType)type userId:(NSString *)userId")));

/// 注册全局评测模式和初始化参数
/// @param config 初始化参数
/// @param type 评测模式
/// @param userId userId（必传）
- (instancetype)initWithManagerConfig:(SSOralEvaluatingManagerConfig *)config type:(OralEvaluatingType)type userId:(NSString *)userId;

/**
 初始化对象

 @param config 初始化参数
 @param type 评测模式
 @return 对象
 */
- (instancetype)initWithManagerConfig:(SSOralEvaluatingManagerConfig *)config type:(OralEvaluatingType)type __attribute__((deprecated("建议使用 initWithManagerConfig:(SSOralEvaluatingManagerConfig *)config type:(OralEvaluatingType)type userId:(NSString *)userId")));

/**
 开始评测

 @param config 评测配置
 */
- (void)startEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config;

/**
 开始评测
 
 @param config 评测配置
 @param storeWavPath 音频存储路径
 */
- (void)startEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config storeWavPath:(NSString *)storeWavPath;

/**
 开始评测(本地音频文件)
 
 @param wavPath 本地音频文件地址
 */
- (void)startEvaluateOralWithWavPath:(NSString *)wavPath config:(SSOralEvaluatingConfig *)config;


/**
 开始评测--不开启录音，需要外部通过- (void)feedAudioToEvaluateWithData:(NSData *)data;传输音频数据到服务器
 
 @param config 评测配置
 */
- (void)startNoAudioStreamEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config;

/**
 传输音频数据（NSData类型）给测评服务器
 注1：使用此方法前，确认通过（- (void)startNoAudioStreamEvaluateOralWithConfig）开启测评
 注2：当每次传输音频数据过大时，ServerTimeout时间要设置长一些。
 */
- (void)feedAudioToEvaluateWithData:(NSData *)data;

/**
 停止评测，返回结果
 */
- (void)stopEvaluate;

/**
 取消评测
 */
- (void)cancelEvaluate;

/**
 引擎释放
 */
-(void)engineDealloc;

/**
 上传本地日志
 @param uid       用户唯一标识
 @param appkey    账号
 @param path      本地日志路径，要与初始化时logPath一致
 @param block     上传回调(code状态值，0:上传成功  ，1:文件正在上传中  ，2:文件不存在  ，3:文件内容为空  ，4:上传失败  ，5:读文件出错)
 */
+(void)uploadLocalLogWithUserID:(NSString *)uid
                         AppKey:(NSString *)appkey
                           Path:(NSString *)path
                       compelet:(void (^)(NSInteger code, NSString * task_id))block;
/**
// 上传本地日志
// @param uid       用户唯一标识
// @param appkey    账号
// @param path      本地日志路径，要与初始化时logPath一致
// @param block     上传回调(code状态值，0:上传成功  ，1:文件正在上传中  ，2:文件不存在  ，3:文件内容为空  ，4:上传失败  ，5:读文件出错)
// @param para     额外的参数
//
// */
//+(void)uploadLocalLogWithUserID:(NSString *)uid
//                         AppKey:(NSString *)appkey
//                           Path:(NSString *)path
//                       compelet:(void (^)(NSInteger code, NSString * task_id))block para:(NSDictionary *)para;

//+(void)uploadLightLog:(NSString *)log AppKey:(NSString *)appkey compelet:(void (^)(NSInteger, NSString *))block;
/**
 清除所有录音文件（只针对调用startEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config)

 @return YES is Success
 */
+ (BOOL)clearAllRecord;

/**
 返回录音文件地址 （只针对调用startEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config)

 @param tokenId 结果的tokenId
 @return 本地录音路径
 */
+ (NSString *)recordPathWithTokenId:(NSString *)tokenId __attribute__((deprecated("建议使用 recordPathWithRequestId:")));

/**
 返回录音文件地址 （只针对调用startEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config)
 
 @param request_id 每次评测对应的request_id
 @return 本地录音路径
 */
+ (NSString *)recordPathWithRequestId:(NSString *)request_id;

/**
 配置授权ID和过期时间
 
 @param warrant_id  授权id
 @param timeout     过期时间戳
 */
- (void)setAuthInfoWithWarrantId:(NSString *)warrant_id AuthTimeout:(NSString *)timeout;


@end


@protocol SSOralEvaluatingManagerDelegate <NSObject>

@optional


/**
 引擎初始化成功
 */
- (void)oralEvaluatingInitSuccess;

/**
 评测开始
 */
- (void)oralEvaluatingDidStart;
/**
 评测停止
 */
- (void)oralEvaluatingDidStop;
/**
 评测完成后的结果
 */
- (void)oralEvaluatingDidEndWithResult: (NSDictionary *)result isLast:(BOOL)isLast;

/**
 评测完成后的结果
 */
- (void)oralEvaluatingDidEndWithResult: (NSDictionary *)result RequestId:(NSString *)request_id;

/**
 边读边评---实时回调
 */
-(void)oralEvaluatingRealTimeCallBack:(NSDictionary *)result;

/**
 评测失败回调
 */
- (void)oralEvaluatingDidEndError: (NSError *)error;

/**
 评测失败回调
 */
- (void)oralEvaluatingDidEndError: (NSError *)error RequestId:(NSString *)request_id;

/**
 录音数据回调
 */
- (void)oralEvaluatingRecordingBuffer: (NSData *)recordingData;

/**
 压缩后的音频数据回调
 */
- (void)oralEvaluatingCompressedRecordBuffer: (NSData *)data isFinish:(BOOL)finish;

/**
 录音音量大小回调
 */
- (void)oralEvaluatingDidUpdateVolume: (int)volume;

/**
 VAD(前置时间）超时回调
 */
- (void)oralEvaluatingDidVADFrontTimeOut;

/**
 VAD(后置时间）超时回调
 */
- (void)oralEvaluatingDidVADBackTimeOut;

/**
 录音即将超时（只支持在线模式，单词20s，句子40s)
 */
- (void)oralEvaluatingDidRecorderWillTimeOut;

/**
 录音文件id回调
 */
- (void)oralEvaluatingReturnRecordId: (NSString *)recordId __attribute__((deprecated("建议使用 oralEvaluatingReturnRequestId:")));

/**
 每次测评对应的request_id回调。
 */
- (void)oralEvaluatingReturnRequestId: (NSString *)request_id;

/**
 开始测评参数配置 拓展参数
 */
-(nullable NSDictionary *)oralEvaluatingStartRefExpand;

/**
 注册引擎参数配置 拓展参数
 */
-(nullable NSDictionary *)oralEvaluatingRegisterRefExpand;

/**
 授权ID需要更新回调
 */
- (void)onWarrantIdNeedUpdate;

@end


