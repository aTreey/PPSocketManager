//
//  ViewController+SendMessage.m
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/14.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//

#import "ViewController+SendMessage.h"

#import <KissXML/KissXML.h>


static NSString *const kFriendName = @"liweipeng@wanzhao.com";
static NSString *const kFriendId = @"506f32124aca4015bb75673822124843";


static NSString *const kName = @"于鸿鹏";
static NSString *const kUserName = @"yuhongpeng@wanzhao.com/app";
static NSString *const kCompanyId = @"1";
static NSString *const kUsesrId = @"8f756551c6b94da198405c2276b522f1";

static NSString *const kmsg = @"msg";
static NSString *const kbusinessType = @"businessType";
static NSString *const kbusinessType_value = @"efeng";
static NSString *const ktype = @"type";
static NSString *const kfrom = @"from";
static NSString *const kto = @"to";
static NSString *const kid = @"id";


static NSString *const kmessageCommon = @"messageCommon";
static NSString *const kbody = @"body";
static NSString *const kcompanyId = @"companyId";
static NSString *const kfromName = @"fromName";         //
static NSString *const ktoName = @"toName";         //
static NSString *const kfromId = @"fromId";
static NSString *const ktoId = @"toId";
static NSString *const kfileName = @"fileName";
static NSString *const ksendTime = @"sendTime";
static NSString *const kmessageId = @"messageId";
static NSString *const klength = @"length";
static NSString *const kstream = @"stream";             // 图片缩略图
static NSString *const kmessageCommon_type = @"type";   // 消息类型（文字，图片，语音，视频，红包....）
static NSString *const kprivateSend = @"privateSend";
static NSString *const kstatus = @"status";
static NSString *const kat = @"ate";




@implementation ViewController (SendMessage)


// 生成消息头部
- (DDXMLElement *)generateXMLHeaderInfo {
    
    DDXMLElement *xmlHeader = [[DDXMLElement alloc] initWithName:kmsg];
    [xmlHeader addAttributeWithName:kbusinessType stringValue:@"efeng"];
    [xmlHeader addAttributeWithName:kfrom stringValue:kUserName];
    [xmlHeader addAttributeWithName:ktype stringValue:@"chat"];
    [xmlHeader addAttributeWithName:kto stringValue:kFriendName];
    [xmlHeader addAttributeWithName:kid stringValue:[self getCurretStamp]]; // 时间戳
    
    return xmlHeader;
}

- (DDXMLNode *)generateXMLNodeWithDict:(NSDictionary *)dict {
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDXMLNode *body = [DDXMLNode elementWithName:kbody stringValue:str];
    return body;
}

- (NSDictionary *)generCommonDictWithBody:(NSString *)body
                         fileName:(NSString *)fileName
                           length:(NSUInteger)length
                           stream:(NSString *)stream
                               at:(NSString *)at
                      messageType:(NSString *)type {
    
    NSMutableDictionary *commoneDict = [NSMutableDictionary dictionary];
    [commoneDict setObject:body forKey:kbody];
    [commoneDict setObject:kCompanyId forKey:kcompanyId];
    [commoneDict setObject:fileName forKey:kfileName];
    [commoneDict setObject:kFriendId forKey:ktoId];
    [commoneDict setObject:[self getCurretStamp] forKey:ksendTime];
    [commoneDict setObject:[self getCurretStamp] forKey:kmessageId];
    [commoneDict setObject:kName forKey:kfromName];
    [commoneDict setObject:@(length) forKey:klength];
    [commoneDict setObject:stream forKey:kstream];
    [commoneDict setObject:@"李伟鹏" forKey:ktoName];
    [commoneDict setObject:@"" forKey:kat];
    [commoneDict setObject:type forKey:ktype];
    [commoneDict setObject:@(0) forKey:kprivateSend];
    [commoneDict setObject:@"0" forKey:kstatus];
    [commoneDict setObject:kUsesrId forKey:kfromId];
    
    return @{kmessageCommon: commoneDict};
}





- (NSString *)videoMessageURL:(NSURL *)videoRUl {
    NSData *data = [NSData dataWithContentsOfURL:videoRUl];
    DDXMLElement *aMessage = [self generateXMLHeaderInfo];
    NSString *body = @"c59c7230f7d041fe8e9afad31146c27b___1516085592842___1516085592842.mp4";
    NSString *fileName = @"c59c7230f7d041fe8e9afad31146c27b___1516085592842___1516085592842.mp4";
    NSString *stream = [data base64EncodedStringWithOptions:0];
    
    
    NSDictionary *commonDict = [self generCommonDictWithBody:body
                                                    fileName:fileName
                                                      length:data.length
                                                      stream:stream
                                                          at:@""
                                                 messageType:@""];
    
    DDXMLNode *bodyNode = [self generateXMLNodeWithDict:commonDict];
    
    [aMessage addChild:bodyNode];
    
    return [aMessage compactXMLString];
    
    
//    <msg businessType="efeng" from="yuhongpeng@baidu.com/app" type="chat" to="liweipeng@baidu.com" id="1516085592842126"><body>{
//        "messageCommon" : {
//            "body" : "c59c7230f7d041fe8e9afad31146c27b___1516085592842___1516085592842.mp4",
//            "companyId" : "3",
//            "fileName" : "c59c7230f7d041fe8e9afad31146c27b___1516085592842___1516085592842.mp4",
//            "sendTime" : "1516085592842",
//            "toId" : "7e825eacb20a4d659bbe38e252340e74",
//            "messageId" : "1516085592842126",
//            "fromName" : "于鸿鹏",
//            "length" : 217820,
//            "stream" : ";;;",
//            "type" : "video",
//            "toName" : "李伟鹏",
//            "status" : "0",
//            "fromId" : "c59c7230f7d041fe8e9afad31146c27b"
//        }
//    }</body></msg>
    
}


/**
 发送图片消息

 @param image 要发送的图片
 @param type 消息类型 （图片时为 "image"）
 @return 返回字符串
 */
- (NSString *)imageMessage:(UIImage *)image messageType:(NSString *)type {
    
    NSData *data = UIImagePNGRepresentation(image);
    NSData *data2 = UIImageJPEGRepresentation(image, 0.1);
    DDXMLElement *aMessage = [self generateXMLHeaderInfo];
    NSString *body = @"0___1516028374630___1516028374630_s.jpg";
    NSString *fileName = @"0___1516028374630___1516028374630_s.jpg";
    NSString *stream = [data2 base64EncodedStringWithOptions:0];

    
    NSDictionary *commonDict = [self generCommonDictWithBody:body
                                                    fileName:fileName
                                                      length:data.length
                                                      stream:stream
                                                          at:@""
                                                 messageType:type];
    
    DDXMLNode *bodyNode = [self generateXMLNodeWithDict:commonDict];
    
    [aMessage addChild:bodyNode];
    
    return [aMessage compactXMLString];
    
// eg:
//    <msg businessType="efeng" from="yuhongpeng@wanzhao.com/app" type="chat" to="liweipeng@wanzhao.com" id="1516028371630158"><body>{
//        "messageCommon" : {
//            "body" : "0___1516028371630___1516028371630_s.jpg",
//            "companyId" : "1",
//            "fileName" : "0___1516028371630___1516028371630_s.jpg",
//            "sendTime" : "1516028887372",
//            "toId" : "506f32124aca4015bb75673822124843",
//            "messageId" : "1516028371630158",
//            "stream" : "qecN8+Pzx+VbKNvUNgj2NADiMqRjNI\r\nisoIfk",
//            "length" : 186756,
//            "fromName" : "于鸿鹏",
//            "type" : "image",
//            "toName" : "李伟鹏",
//            "status" : "0",
//            "fromId" : "8f756551c6b94da198405c2276b522f1"
//        }
//    }</body></msg>
}


// 发普通消息
- (NSString *)textMessage:(NSString *)mesage messageType:(NSString *)type {
    
    DDXMLElement *aMessage = [[DDXMLElement alloc] initWithName:kmsg];
    [aMessage addAttributeWithName:kbusinessType stringValue:@"efeng"];
    [aMessage addAttributeWithName:kfrom stringValue:kUserName];
    [aMessage addAttributeWithName:ktype stringValue:@"chat"];
    [aMessage addAttributeWithName:kto stringValue:@"liweipeng@wanzhao.com"];
    [aMessage addAttributeWithName:kid stringValue:[self getCurretStamp]]; // 时间戳
    
    NSMutableDictionary *commoneDict = [NSMutableDictionary dictionary];
    [commoneDict setObject:mesage forKey:kbody];
    [commoneDict setObject:kCompanyId forKey:kcompanyId];
    [commoneDict setObject:@"" forKey:kfileName];
    [commoneDict setObject:kFriendId forKey:ktoId];
    [commoneDict setObject:[self getCurretStamp] forKey:ksendTime];
    [commoneDict setObject:[self getCurretStamp] forKey:kmessageId];
    [commoneDict setObject:kName forKey:kfromName];
    [commoneDict setObject:@"" forKey:klength];
    [commoneDict setObject:@"" forKey:kstream];
    [commoneDict setObject:@"李伟鹏" forKey:ktoName];
    [commoneDict setObject:@"" forKey:kat];
    [commoneDict setObject:type forKey:ktype];
    [commoneDict setObject:@(0) forKey:kprivateSend];
    [commoneDict setObject:@"0" forKey:kstatus];
    [commoneDict setObject:kUsesrId forKey:kfromId];
    
    NSDictionary *bodyDic = @{kmessageCommon: commoneDict};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:bodyDic options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDXMLNode *body = [DDXMLNode elementWithName:kbody stringValue:str];
    
    [aMessage addChild:body];
    
    // TODO: 处理将要发送的消息，插入到数据库 ?
    return [aMessage compactXMLString];
}




// 发回执
- (NSString *)sendReceiptStrWithMessageId:(NSString *)messageId {
    DDXMLElement *receipt = [[DDXMLElement alloc] initWithName:@"msg"];
    [receipt addAttributeWithName:@"reply" stringValue:@"yes"];
    [receipt addAttributeWithName:@"type" stringValue:@"normal"];
    [receipt addAttributeWithName:@"to" stringValue:@"@server"];
    [receipt addAttributeWithName:@"id" stringValue:messageId];
    return [receipt compactXMLString];
}

// call center telephoneNumber
- (NSString *)sendCallCenterTelephoneNumberStr {
    DDXMLElement *aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"callTelephoneNumber"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"callTelephoneNumber"];
    DDXMLNode *child =[DDXMLNode elementWithName:@"userId" stringValue:kUsesrId];
    DDXMLNode *query = [DDXMLNode elementWithName:@"query" children:[NSArray arrayWithObjects:child, nil] attributes:[NSArray arrayWithObjects:attrs, nil]];
    [aIQ addChild:query];
    return [aIQ compactXMLString];
}

// 列表Recent Contact IQ
- (NSString *)sendUserProfileSettingIQStr {
    DDXMLElement *aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"appmsgNoticeSetGet"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"appmsgNoticeSetGet"];
    [aIQ addChild:[DDXMLNode elementWithName:@"query" children:nil attributes:[NSArray arrayWithObjects:attrs, nil]]];
    return [aIQ compactXMLString];
}

// 获紧急联系人列表 IQ
- (NSString *)sendEmergencyContactsListIQStr {
    DDXMLElement *aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"contacturgencyList"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"contacturgencyList"];
    DDXMLNode *child =[DDXMLNode elementWithName:@"userId" stringValue:kUsesrId];
    DDXMLNode *query = [DDXMLNode elementWithName:@"query" children:[NSArray arrayWithObjects:child, nil] attributes:[NSArray arrayWithObjects:attrs, nil]];
    [aIQ addChild:query];
    
    return [aIQ compactXMLString];
}

// 最近联系人列表 IQ
- (NSString *)sendRecentContactsListIQStr {
    DDXMLElement *aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"contactList"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"contactList"];
    DDXMLNode *child =[DDXMLNode elementWithName:@"userId" stringValue:kUsesrId];
    DDXMLNode *query = [DDXMLNode elementWithName:@"query" children:[NSArray arrayWithObjects:child, nil] attributes:[NSArray arrayWithObjects:attrs, nil]];
    [aIQ addChild:query];
    
    return [aIQ compactXMLString];
}



// 获取客服列表 IQ
- (NSString *)sendCustomerCenterListIQStr {
    DDXMLElement * aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"getcompanykf"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"getcompanykf"];
    DDXMLNode *attrs3 = [DDXMLNode elementWithName:@"companyId" stringValue:kUsesrId];
    DDXMLNode *query = [DDXMLNode elementWithName:@"query" children:[NSArray arrayWithObjects:attrs3, nil] attributes:[NSArray arrayWithObjects:attrs, nil]];
    [aIQ addChild:query];
    return [aIQ compactXMLString];
}

// 发送token IQ
- (NSString *)uploadTokenStr {
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    token = @"123243546";
    if (!token) {
        return nil;
    }
    
    DDXMLElement *element = [DDXMLElement elementWithName:@"iq"];
    [element addAttributeWithName:@"id" stringValue:@"setToken"];
    DDXMLNode *child = [DDXMLNode elementWithName:@"token" stringValue:[NSString stringWithFormat:@"ios,%@", token]];
    DDXMLNode *iqType = [DDXMLNode attributeWithName:@"iqType" stringValue:@"setToken"];
    DDXMLNode *queryAttrs = [DDXMLNode elementWithName:@"query" children:@[child] attributes:@[iqType]];
    
    [element addChild:queryAttrs];
    return [element compactXMLString];
}

// 发送登陆消息
- (NSString *)sendLoginMessageStr {
    DDXMLElement *peopleElement = [DDXMLElement elementWithName:@"login"];
    DDXMLNode *useName = [DDXMLNode attributeWithName:@"from" stringValue:kUserName];
    DDXMLNode *passWord = [DDXMLNode attributeWithName:@"password" stringValue:@"@123456Zw"];
    DDXMLNode *businessType =[DDXMLNode attributeWithName:@"businessType" stringValue:@"efeng"];
    [peopleElement addAttribute:useName];
    [peopleElement addAttribute:passWord];
    [peopleElement addAttribute:businessType];
    return [peopleElement compactXMLString];
}


// 发送ping 包

- (NSString *)sendPingStr {
    DDXMLElement *pingElement = [DDXMLElement elementWithName:@"ping"];
    DDXMLNode *userName = [DDXMLNode attributeWithName:@"from" stringValue:kUserName];
    [pingElement addAttribute:userName];
    return [pingElement compactXMLString];
}


- (NSString *)getCurretStamp {
    NSTimeInterval stamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *stampStr = [NSString stringWithFormat:@"%f", stamp];
    return [[stampStr componentsSeparatedByString:@"."] firstObject];
}

@end
