//
//  ViewController.m
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/12.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//

#import "ViewController.h"
#import <KissXML/KissXML.h>

#import "SocketManager.h"
#import "DDXMLElement+Extension.h"
#import "ViewController+HandleMessageIQ.h"
#import "ViewController+HandleMessage.h"

#import "ViewController+SendMessage.h"


static NSString *const kUserName = @"yuhongpeng@wanzhao.com/app";
static NSString *const kCompanyId = @"1";
static NSString *const kUsesrId = @"8f756551c6b94da198405c2276b522f1";


@interface ViewController () <SocketManagerDelegate>

@property (nonatomic, strong) SocketManager *manager;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _manager = [SocketManager instance];
    _manager.delegate = self;
    
    [_manager connect];
}


// 登陆
- (IBAction)loginAction:(id)sender {
    
    [_manager connect];
//
//    [self loginMessage];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self pingData];
//    });
}



- (IBAction)pingAction:(id)sender {
    
    
    [self sendPing];

}

- (IBAction)disconnect:(id)sender {
    
//    [self.manager disconnect];
}

- (IBAction)messageAction:(id)sender {
}



- (IBAction)iQAction:(id)sender {
    
    [self uploadToken];
    
//    [self sendCustomerCenterListIQ];
//    [self sendRecentContactsListIQ];
//    [self sendEmergencyContactsListIQ];
//    [self sendUserProfileSettingIQ];
//    [self sendCallCenterTelephoneNumber];
    
    [self.manager sendMsg:[self sendEmergencyContactsListIQStr] type:MessageTypeIq];
    [self.manager sendMsg:[self sendUserProfileSettingIQStr] type:MessageTypeIq];
    
}

// 登陆

- (IBAction)textmessageAction:(id)sender {

    [self.manager sendMsg:[self textMessage:@"普通消息---鹏哥，你好" messageType:@"text"] type:MessageTypeMessage];
    
}
- (IBAction)imageMessageAction:(id)sender {
    
    UIImage *image = [UIImage imageNamed:@"123"];
    [self.manager sendMsg:[self imageMessage:image messageType:@"image"] type:MessageTypeMessage];
}

- (IBAction)takePhotoAction:(id)sender {
    

}
- (IBAction)videoMessageAction:(id)sender {
    

}
- (IBAction)fileMessageAction:(id)sender {

}
- (IBAction)locationMessage:(id)sender {
    

}
- (IBAction)redPacketMessage:(id)sender {
    

}

- (IBAction)privateMessage:(id)sender {
    

}

- (IBAction)atSomeoneMessage:(id)sender {
    

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    [_manager disconnect];

}


#pragma mark - SocketManagerDelegate

// 连接成功
- (void)socketManager:(SocketManager *)manager didConnect:(NSString *)host port:(uint16_t)port {
        
    [self sendLoginMessage];
    NSLog(@" 连接成功 status = %zd", [manager isConnect]);
    
}


// 断开连接
- (void)socketManager:(SocketManager *)manager didDisconnectWithError:(NSError *)error {
    
    NSString *messagId = @"";
    // TODO: 1. 获取正在发送失败的消息,
    // 2. 插入到数据库
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 3. 发送通知,更新相关UI界面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Message_send_status" object:messagId];
    });
    
    
    
    /// 处理相关错误
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        
    });
    
    
    NSLog(@" 断开 status = %zd", [manager isConnect]);
}


- (void)socketManager:(SocketManager *)manager didReadString:(NSString *)str type:(MessageType)type {
    
    DDXMLElement *element = [[DDXMLElement alloc] initWithXMLString:str error:nil];
    
    switch (type) {
        case MessageTypeLogin:
            NSLog(@"登陆结果");
            
            [self handleLoginWithElement:element];
            
            break;
            
        case MessageTypePing:
//            NSLog(@"接收到ping包");
            break;
            
        case MessageTypeMessage:
            NSLog(@"接收收到消息");
        {
            
            NSString *messageId = [self handleReceiveMessageWithElement:element];
            if (messageId) {
                [self sendReceiptWithMessageId:messageId];
            }
            
        }
            
            break;
            
        case MessageTypeIq:
            
            [self handleIqWithElement:element];

            
            NSLog(@"接收到IQ");
            break;
            
        case MessageTypePresence:
            
            [self handlePresenceWithElement:element];

            NSLog(@"接收到在线状态");
            break;
            
            
        default:
            break;
    }
    
    NSLog(@"\n\n\n %@", str);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 解析登陆
- (void)handleLoginWithElement:(DDXMLElement *)element {
    DDXMLNode *node = [element attributeForName:@"issuccess"];

    if ([node.stringValue isEqualToString:@"yes"]) {
        
        NSLog(@"\n\n**************用户登陆成功**************\n\n");
        
        // 1 发送ping包
        [self sendPing];
        
        // TODO: 2 发送登陆成功通知，切换根控制器
        
        // 3 获取服务器时间
        
        // 4 发送token，用于APNS推送 （http）
        
        
        // 5. 获取组织架构树 （http）
        
        // 6. 获取群组列表 （http）
        
        // 7. 获取分享相关 （http）
        
        // 8. 获取分享关注我的，我关注的人 （http）
        
        // 9. CXmppRequestMgr 获取客服, 常用联系人， 紧急联系人列表, 个人设置， 呼叫中心电话号码  （IQ）
        
//        [self sendCustomerCenterListIQ];
//        [self sendRecentContactsListIQ];
//        [self sendEmergencyContactsListIQ];
//        [self sendUserProfileSettingIQ];
//        [self sendCallCenterTelephoneNumber];
        
        
        
        // 10. 获取服务器配置  （http）
        // 11. CXmppRequestMgr 获取客服 （IQ）
        // 12. CXmppRequestMgr 获取客服 （IQ）
        // 13. CXmppRequestMgr 获取客服 （IQ）
        // 14. CXmppRequestMgr 获取客服 （IQ）

        
    }
    
    // 登陆不成功
    else {
        [self.manager stopReconnect];
        
        // 错误原因
        NSMutableDictionary *loginResultDict = [NSMutableDictionary dictionary];
        [loginResultDict setObject:@"false" forKey:@"result"];
        [loginResultDict setObject:node.stringValue forKey:@"error"];
        
        // TODO: 发送不成功通知及错误原因
    }
}






// 处理发送的消息
- (void)parseMessageBody:(DDXMLElement *)element isGroupChat:(BOOL)groupChat {
    
    NSString *body = [[element elementForName:@"body"] stringValue];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//    NSDictionary *commonDict = dict[@"messageCommon"];
    
    // TODO: 转换为消息模型
    NSLog(@"\nmessage == %@", dict);
}




#pragma mark - 解析出席状态
- (void)handlePresenceWithElement:(DDXMLElement *)element {
    
    
}


#pragma mark -
#pragma mark -




/////////////////////////////////////////////////////
///以下代码用 sendMessage 分类代替
/////////////////////////////////////////////////////
#pragma mark - 发送消息


// 发普通消息
- (void)sendTextMessageId:(NSString *)messageId {
    
}


// 发回执
- (void)sendReceiptWithMessageId:(NSString *)messageId {
    DDXMLElement *receipt = [[DDXMLElement alloc] initWithName:@"msg"];
    [receipt addAttributeWithName:@"reply" stringValue:@"yes"];
    [receipt addAttributeWithName:@"type" stringValue:@"normal"];
    [receipt addAttributeWithName:@"to" stringValue:@"@server"];
    [receipt addAttributeWithName:@"id" stringValue:messageId];
    [self.manager sendMsg:[receipt compactXMLString] type:MessageTypeMessage];
}

// call center telephoneNumber
- (void)sendCallCenterTelephoneNumber {
    DDXMLElement *aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"callTelephoneNumber"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"callTelephoneNumber"];
    DDXMLNode *child =[DDXMLNode elementWithName:@"userId" stringValue:kUsesrId];
    DDXMLNode *query = [DDXMLNode elementWithName:@"query" children:[NSArray arrayWithObjects:child, nil] attributes:[NSArray arrayWithObjects:attrs, nil]];
    [aIQ addChild:query];
    
    [self.manager sendMsg:[aIQ compactXMLString] type:MessageTypeIq];
}

// 列表Recent Contact IQ
- (void)sendUserProfileSettingIQ {
    DDXMLElement *aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"appmsgNoticeSetGet"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"appmsgNoticeSetGet"];
    [aIQ addChild:[DDXMLNode elementWithName:@"query" children:nil attributes:[NSArray arrayWithObjects:attrs, nil]]];
    [self.manager sendMsg:[aIQ compactXMLString] type:MessageTypeIq];
}

// 获紧急联系人列表 IQ
- (void)sendEmergencyContactsListIQ {
    DDXMLElement *aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"contacturgencyList"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"contacturgencyList"];
    DDXMLNode *child =[DDXMLNode elementWithName:@"userId" stringValue:kUsesrId];
    DDXMLNode *query = [DDXMLNode elementWithName:@"query" children:[NSArray arrayWithObjects:child, nil] attributes:[NSArray arrayWithObjects:attrs, nil]];
    [aIQ addChild:query];
    
    [self.manager sendMsg:[aIQ compactXMLString] type:MessageTypeIq];
}

// 最近联系人列表 IQ
- (void)sendRecentContactsListIQ {
    DDXMLElement *aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"contactList"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"contactList"];
    DDXMLNode *child =[DDXMLNode elementWithName:@"userId" stringValue:kUsesrId];
    DDXMLNode *query = [DDXMLNode elementWithName:@"query" children:[NSArray arrayWithObjects:child, nil] attributes:[NSArray arrayWithObjects:attrs, nil]];
    [aIQ addChild:query];
    
    [self.manager sendMsg:[aIQ compactXMLString] type:MessageTypeIq];
}



// 获取客服列表 IQ
- (void)sendCustomerCenterListIQ {
    DDXMLElement * aIQ = [[DDXMLElement alloc] initWithName:@"iq"];
    [aIQ addAttributeWithName:@"id" stringValue:@"getcompanykf"];
    DDXMLNode *attrs =[DDXMLNode attributeWithName:@"iqType" stringValue:@"getcompanykf"];
    DDXMLNode *attrs3 = [DDXMLNode elementWithName:@"companyId" stringValue:kUsesrId];
    DDXMLNode *query = [DDXMLNode elementWithName:@"query" children:[NSArray arrayWithObjects:attrs3, nil] attributes:[NSArray arrayWithObjects:attrs, nil]];
    [aIQ addChild:query];
    
    [self.manager sendMsg:[aIQ compactXMLString] type:MessageTypeIq];
}

// 发送token IQ
- (void)uploadToken {
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    token = @"123243546";
    if (!token) {
        return;
    }
    
    DDXMLElement *element = [DDXMLElement elementWithName:@"iq"];
    [element addAttributeWithName:@"id" stringValue:@"setToken"];
    DDXMLNode *child = [DDXMLNode elementWithName:@"token" stringValue:[NSString stringWithFormat:@"ios,%@", token]];
    DDXMLNode *iqType = [DDXMLNode attributeWithName:@"iqType" stringValue:@"setToken"];
    DDXMLNode *queryAttrs = [DDXMLNode elementWithName:@"query" children:@[child] attributes:@[iqType]];
    
    [element addChild:queryAttrs];
    NSString *iq = [element compactXMLString];
    [self.manager sendMsg:iq type:MessageTypeIq];
    
}

// 发送登陆消息
- (void)sendLoginMessage {
    DDXMLElement *peopleElement = [DDXMLElement elementWithName:@"login"];
    DDXMLNode *useName = [DDXMLNode attributeWithName:@"from" stringValue:kUserName];
    DDXMLNode *passWord = [DDXMLNode attributeWithName:@"password" stringValue:@"@123456Zw"];
    DDXMLNode *businessType =[DDXMLNode attributeWithName:@"businessType" stringValue:@"efeng"];
    [peopleElement addAttribute:useName];
    [peopleElement addAttribute:passWord];
    [peopleElement addAttribute:businessType];
    NSString *str = [peopleElement compactXMLString];
    [self.manager sendMsg:str type:MessageTypeLogin];
}


// 发送ping 包

- (void)sendPing {
    self.manager.pingData = [[self sendPingStr] dataUsingEncoding:NSUTF8StringEncoding];
    [self.manager.pingTimer setFireDate:[NSDate distantPast]];
}

@end
