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



@end
