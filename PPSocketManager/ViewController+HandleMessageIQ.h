//
//  ViewController+HandleMessageIQ.h
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/14.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//

#import "ViewController.h"
#import <KissXML/KissXML.h>


@interface ViewController (HandleMessageIQ)

- (void)handleIqWithElement:(DDXMLElement *)element;

@end
