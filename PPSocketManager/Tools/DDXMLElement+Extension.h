//
//  DDXMLElement+Extension.h
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/13.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//

#import <KissXML/KissXML.h>

@interface DDXMLElement (Extension)


// 是否单聊
- (BOOL)isChat;

// 是否群聊
- (BOOL)isGroupChat;

@end
