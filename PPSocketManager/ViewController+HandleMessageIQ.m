//
//  ViewController+HandleMessageIQ.m
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/14.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//

#import "ViewController+HandleMessageIQ.h"

@implementation ViewController (HandleMessageIQ)


- (void)handleIqWithElement:(DDXMLElement *)element {
    
    if (!element) {
        return;
    }
    
    NSString *elementId = [element attributeForName:@"id"].stringValue;
    
    if (!element) {
        NSLog(@"iq 的id 为空");
        return;
    }
    
    if ([elementId isEqualToString:@"getcompanykf"]) {
        
        NSString *string = [element elementForName:@"result"].stringValue;
        [self parseCustomerCenterList:string];
        
    } else if ([elementId isEqualToString:@"contactList"]) {
        
        NSString *string = [element elementForName:@"result"].stringValue;
        [self elementStringToArray:string];
        
    } else if ([elementId isEqualToString:@"contacturgencyList"]) {
        NSString *string = [element elementForName:@"contact"].stringValue;
        [self elementStringToArray:string];
        
    } else if ([elementId isEqualToString:@"appmsgNoticeSetGet"]) {
        NSString *string = [element elementForName:@"result"].stringValue;
        [self elementStringToArray:string];
        
    }
    
    
    else if ([elementId isEqualToString:@"userinfomodify"]) {
        NSString *string = [element elementForName:@"result"].stringValue;
        [self elementStringToArray:string];
        
        
    } else if ([elementId isEqualToString:@""]) {
        NSString *string = [element elementForName:@"result"].stringValue;
        [self elementStringToArray:string];
    } else if ([elementId isEqualToString:@""]) {
        NSString *string = [element elementForName:@"result"].stringValue;
        [self elementStringToArray:string];
    } else if ([elementId isEqualToString:@""]) {
        NSString *string = [element elementForName:@"result"].stringValue;
        [self elementStringToArray:string];
    } else if ([elementId isEqualToString:@""]) {
        NSString *string = [element elementForName:@"result"].stringValue;
        [self elementStringToArray:string];
    } else if ([elementId isEqualToString:@""]) {
        NSString *string = [element elementForName:@"result"].stringValue;
        [self elementStringToArray:string];
    }
    
    
    
}


- (void)parseRecentContactsList:(NSString *)string {
    
    
    
    
    
}

// 客服列表
- (void)parseCustomerCenterList:(NSString *)string {
    
    if (!string.length) {
        return;
    }
    
    NSArray *array = [self elementStringToArray:string];
    NSLog(@"客服list = %@", array);
}


- (NSArray *)elementStringToArray:(NSString *)string {
    // NSJSONReadingAllowFragments 非标准json 时使用
    
    if (!string) {
        NSLog(@"IQ 中的信息为空");
        return nil;
    }
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if ([jsonObj isKindOfClass:[NSArray class]]) {
         NSLog(@"\n\nIQ_list = %@", (NSArray *)jsonObj);
        return (NSArray *)jsonObj;
    }
    
    
    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dict = (NSDictionary *)jsonObj;
        NSLog(@"\n\nIQ = %@", dict);
        return @[dict];
    }
    
    return nil;
}


@end
