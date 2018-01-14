//
//  ViewController+HandleMessage.m
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/14.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//

#import "ViewController+HandleMessage.h"
#import "DDXMLElement+Extension.h"


@implementation ViewController (HandleMessage)


#pragma mark - 解析消息
- (NSString *)handleReceiveMessageWithElement:(DDXMLElement *)element {
    
    if ([element isChat]) {
         return [self handleMessageBody:element isGroupChat:NO];
    } else {
         return [self handleMessageBody:element isGroupChat:NO];
    }
}


// 处理发送的消息
- (NSString *)handleMessageBody:(DDXMLElement *)element isGroupChat:(BOOL)groupChat {
    
    NSString *body = [[element elementForName:@"body"] stringValue];
    NSString *isOffline = [[element attributeForName:@"subject"] stringValue];
    NSString *messageId = [element attributeForName:@"id"].stringValue;
    NSString *reply = [[element attributeForName:@"reply"] stringValue];

    
    // 消息回执
    if ([reply isEqualToString:@"yes"]) {
        return nil;
    }
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    NSString *type = nil;
    NSDictionary *commonDict = nil;
    
    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)jsonObj;
        commonDict = [dict objectForKey:@"messageCommon"];
        type = [commonDict objectForKey:@"type"];
    }
    
    
    NSArray *offlineMessage = nil;
    if ([jsonObj isKindOfClass:[NSArray class]]) {
        offlineMessage = (NSArray *)jsonObj;
        type = [commonDict objectForKey:@"type"];
    }
    
    
    // 撤销
    if ([type isEqualToString:@"revoke"]) {
        
    }
    
    
    // 离线消息
    if ([isOffline isEqualToString:@"offline"]) {
        
        NSLog(@"\n\n messageType = %@ message == %@",isOffline, offlineMessage);
        
        
        // 放入到离线数组中，
        
        // 判断是否有撤回的消息，有撤回，需要删除
        
        // 插入到数据库
        
        // 发送回执消息
        
    } else {
        
        //  在线消息
        if ([type isEqualToString:@"text"] || [type isEqualToString:@"faceGif"] ||
            [type isEqualToString:@"file"] || [type isEqualToString:@"voice"] ||
            [type isEqualToString:@"redpacket"] || [type isEqualToString:@"video"] ||
            [type isEqualToString:@"news"]) {
            
            
            
        }
        
        // 系统通知消息
        else if ([type hasPrefix:@"worknotice"] || [type hasPrefix:@"systemnotice"]) {
            
        } else if ([type isEqualToString:@"text"]) {
    
    
        } else if ([type isEqualToString:@"text"]) {
    
    
        } else if ([type isEqualToString:@"text"]) {
    
    
        } else if ([type isEqualToString:@"text"]) {
    
    
        } else if ([type isEqualToString:@"text"]) {
    
        } else {
            
        }
        
        // TODO: 转换为消息模型
        
        
        // 插入到本地数据库成功以后再发送回执消息
        
        NSLog(@"\n\n messageType = %@ message == %@",isOffline, offlineMessage);
    }
    
    return messageId;
}

@end
