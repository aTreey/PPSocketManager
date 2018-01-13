//
//  DDXMLElement+Extension.m
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/13.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//

#import "DDXMLElement+Extension.h"

@implementation DDXMLElement (Extension)

- (BOOL)isChat {
    NSString *type = [self attributeForName:@"type"].stringValue;
    return [type isEqualToString:@"chat"];
}

- (BOOL)isGroupChat {
    NSString *type = [self attributeForName:@"type"].stringValue;
    return [type isEqualToString:@"groupchat"];
}


@end
