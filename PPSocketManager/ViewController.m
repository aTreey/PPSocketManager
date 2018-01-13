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


static NSString *const kUserName = @"yuhongpeng@wanzhao.com";

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
    
    [self loginMessage];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self pingData];
    });
}



- (IBAction)pingAction:(id)sender {
    
    
//    [self pingData];

}


- (IBAction)messageAction:(id)sender {
}



- (IBAction)iQAction:(id)sender {
    
    [self uploadToken];
    
}

// 登陆


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    [_manager disconnect];

}


#pragma mark - SocketManagerDelegate

- (void)socketManager:(SocketManager *)manager didConnect:(NSString *)host port:(uint16_t)port {
    
    NSLog(@"status = %zd", [manager isConnect]);
    
}

- (void)socketManager:(SocketManager *)manager didDisconnectWithError:(NSError *)error {
    
    NSLog(@"status = %zd", [manager isConnect]);
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
            
            [self handleReceiveMessageWithElement:element];

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

#pragma mark - 处理接收到的消息

- (void)handleReceiveMessageWithElement:(DDXMLElement *)element {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 解析消息

#pragma mark - 解析登陆
- (void)handleLoginWithElement:(DDXMLElement *)element {
    DDXMLNode *node = [element attributeForName:@"issuccess"];

    if ([node.stringValue isEqualToString:@"yes"]) {
        // 1 发送ping包
        [self pingData];
        
        // TODO: 2 发送登陆成功通知，切换根控制器
        
        // 3 获取服务器时间
        
        // 4 发送token，用于APNS推送
    }
    
    // 登陆不成功
    else {
        
        [self.manager.reConnectTimer setFireDate:[NSDate distantFuture]];
        [self.manager.reConnectTimer invalidate];
        
        // 错误原因
        NSMutableDictionary *loginResultDict = [NSMutableDictionary dictionary];
        [loginResultDict setObject:@"false" forKey:@"result"];
        [loginResultDict setObject:node.stringValue forKey:@"error"];
        
        // TODO: 发送不成功通知及错误原因
    }
}



#pragma mark - 解析消息
- (void)handleMessageWithElement:(DDXMLElement *)element {
    
    if ([element isChat]) {
        [self parseMessageBody:element isGroupChat:NO];
    }
    
    else if ([element isGroupChat]) {
        [self parseMessageBody:element isGroupChat:YES];
    }
    
    else {
        
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


#pragma mark - 解析IQ
- (void)handleIqWithElement:(DDXMLElement *)element {
    
    
}

#pragma mark - 解析出席状态
- (void)handlePresenceWithElement:(DDXMLElement *)element {
    
    
}


#pragma mark -
#pragma mark -





#pragma mark - 发送消息
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
- (void)loginMessage {
    DDXMLElement *peopleElement = [DDXMLElement elementWithName:@"login"];
    DDXMLNode *useName = [DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@/app",@"yuhongpeng@wanzhao.com"]];
    DDXMLNode *passWord = [DDXMLNode attributeWithName:@"password" stringValue:@"@123456Zw"];
    DDXMLNode *businessType =[DDXMLNode attributeWithName:@"businessType" stringValue:@"efeng"];
    [peopleElement addAttribute:useName];
    [peopleElement addAttribute:passWord];
    [peopleElement addAttribute:businessType];
    NSString *str = [peopleElement compactXMLString];
    [self.manager sendMsg:str type:MessageTypeLogin];
}


// 发送ping 包

- (void)pingData {
    DDXMLElement *pingElement = [DDXMLElement elementWithName:@"ping"];
    DDXMLNode *userName = [DDXMLNode attributeWithName:@"from" stringValue:kUserName];
    [pingElement addAttribute:userName];
    NSString *str = [pingElement compactXMLString];
    self.manager.pingData = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self.manager.pingTimer setFireDate:[NSDate distantPast]];
}

@end
