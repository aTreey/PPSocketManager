//
//  ViewController+SendMessage.h
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/14.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (SendMessage)

- (NSString *)sendPingStr;
- (NSString *)sendLoginMessageStr;
- (NSString *)uploadTokenStr;
- (NSString *)sendReceiptStrWithMessageId:(NSString *)messageId;
- (NSString *)sendCallCenterTelephoneNumberStr;
- (NSString *)sendUserProfileSettingIQStr;
- (NSString *)sendEmergencyContactsListIQStr;
- (NSString *)sendRecentContactsListIQStr;
- (NSString *)sendCustomerCenterListIQStr;

- (NSString *)textMessage:(NSString *)mesage messageType:(NSString *)type;

//- (NSData *)imageMessage:(UIImage *)image messageType:(NSString *)type;

- (NSString *)imageMessage:(UIImage *)image messageType:(NSString *)type;


/**
 发送视频
 @param videoRUl 视频URL
 @return return 返回字符串
 */
- (NSString *)videoMessageURL:(NSURL *)videoRUl;

@end
