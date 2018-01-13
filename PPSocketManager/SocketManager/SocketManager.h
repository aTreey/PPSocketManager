//
//  SocketManager.h
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/12.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//



#import <Foundation/Foundation.h>

@class SocketManager;

// 消息类型
typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeLogin = 0,       // 登陆
    MessageTypePing,            // 心跳ping包
    MessageTypeMessage,         // 消息类型
    MessageTypeIq,          // 请求或者响应类型
    MessageTypePresence,        // 出席类型
};



@protocol SocketManagerDelegate <NSObject>

- (void)socketManager:(SocketManager *)manager didConnect:(NSString *)host port:(uint16_t)port;

- (void)socketManager:(SocketManager *)manager didDisconnectWithError:(NSError *)error;

- (void)socketManager:(SocketManager *)manager didReadString:(NSString *)str type:(MessageType)type;

@end



@interface SocketManager : NSObject


@property (nonatomic, weak) id<SocketManagerDelegate> delegate;

/// ping包
@property (nonatomic, strong) NSData *pingData;

/// 心跳定时器
@property (nonatomic, strong) NSTimer *pingTimer;
/// 重连定时器
@property (nonatomic, strong) NSTimer *reConnectTimer;

// 实例化对象
+ (instancetype)instance;


/**
 连接状态

 @return BOOL
 */
- (BOOL)isConnect;

/**
  连接
 */
- (void)connect;

/**
 断开连接
 */
- (void)disconnect;

/**
 发送消息

 @param msg 数据内容
 @param type 数据类型

 */
- (void)sendMsg:(NSString *)msg type:(MessageType)type;


@end
