//
//  SocketManager.m
//  PPSocketManager
//
//  Created by HongpengYu on 2018/1/12.
//  Copyright © 2018年 HongpengYu. All rights reserved.
//

#import "SocketManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>



static NSString *const Khost = @"101.200.210.161";
static const uint16_t Kport = 8613;
static const NSTimeInterval timeOut = -1;
static const long tag = 110;

//NSString *const delegateQueueName = @"hongpeng.com_delegateQueueName";


@interface SocketManager () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

/// 数据缓冲区
@property (nonatomic, strong) NSMutableData *buffer;
@property (nonatomic, strong) NSData *pingPacket;


/// socket代理 队列
@property (nonatomic, strong) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) dispatch_queue_t sendQueue;
@property (nonatomic, strong) dispatch_queue_t receiveQueue;


@end



@implementation SocketManager

+ (instancetype)instance {
    static SocketManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (instancetype)init {
    if (self = [super init]) {
        [self initSocket];
    }
    return self;
}


// 发送消息
- (void)sendMsg:(NSString *)msg type:(MessageType)type {
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSData *packetData = [self packetWithData:data messageType:type];
    
    dispatch_async(self.sendQueue, ^{
        [self.socket writeData:packetData withTimeout:timeOut tag:tag];
    });
}



/**
 封包: 1. 头部标识, 2. 数据类型, 3.文件长度, 4.实际数据包

 @param data 二进制数据流
 @param type 数据类型
 @return 增加了数据头部信息(长度，类型)的数据包
 */
- (NSData *)packetWithData:(NSData *)data messageType:(MessageType)type {
    
    /// 1. 封装实际数据长度
    // 获取长度
    NSInteger third = data.length;
    
    // 定义C语言指针,通过指针 p_json3 操作third所在地址的字符数据
    char *p_json3 = (char *)&third;
    
    // 定义4个字符长度的C语言 字符数组，并全部初始化为 0
    char str_json3[4] = {0};
    
    for(int i= 0 ;i < 4 ;i++)
        
    {
        // 将指针 p_json3 指向的数据添加到 C 字符数组中
        str_json3[i] = *p_json3;
        p_json3 ++;
    }
    
    
    /// 2. 封装数据头部标识
    // 指定头部标识长度
    int first = 1048576;
    char *p_json1 = (char *)&first;
    char str_json1[4] = {0};
    // 头部标识占 4 个字节
    for(int i= 0 ;i < 4 ;i++)
        
    {
        str_json1[i] = *p_json1;
        p_json1 ++;
    }
    
    
    int second;
    switch (type) {
        case MessageTypeLogin:
        {
            second = 1024;
        }
            break;
        case MessageTypePing:
        {
            second = 2048;
        }
            break;
        case MessageTypeMessage:
        {
            second = 4096;
        }
            break;
        case MessageTypeIq:
        {
            second = 3072;
        }
            break;
        default:
            break;
    }
    
    /// 3.处理数据类型
    // 根据处理数据类型
    char *p_json2 = (char *)&second;
    char str_json2[4] = {0};
    
    for(int i= 0 ;i < 4 ;i++)
        
    {
        str_json2[i] = *p_json2;
        p_json2 ++;
    }
    NSMutableData *newData = [NSMutableData data];
    [newData appendBytes:str_json1 length:4];
    [newData appendBytes:str_json2 length:4];
    [newData appendBytes:str_json3 length:4];
    if (data) {
        Byte *bytes = (Byte *)[data bytes];
        for (int i=0;i<[data length];i++) {
            bytes[i] = (Byte)(bytes[i] ^ 0xFF);
        }
        [newData appendData:[NSData dataWithBytes:bytes length:data.length]];
    }
    return newData;
}


- (void)unpackWithData:(NSData *)data {
    
    if (data.length) {
        // 添加到缓冲区
        [self.buffer appendData:data];
    }
    
    // 解包数据
    dispatch_async(self.receiveQueue, ^{
        
        // 根据报文头部长度 12 字节 解析
        while (self.buffer.length >= 12) {
            // 包头占 4byte
            // 包类型占 4byte
            // 包长度占 4byte
            
            // 解析类型，从下标为4的地方开始
            NSData *typeData = [self.buffer subdataWithRange:NSMakeRange(4, 4)];
            MessageType type = [self parseDataTypeWithTypeData:typeData];
            
            
            // 解析长度
            NSData *lengthData = [self.buffer subdataWithRange:NSMakeRange(8, 4)];
            NSInteger length = [self bytesToIntWithData:lengthData];
            
            // 获取实际的消息数据 长度需 + 报文头部信息的长度（包头+类型+包长度 = 12）
            NSData *data = [self subdataFromBufferWithLength:length + 12];
            // 按位异或解密
            if (data) {
                NSString *string = [[NSString alloc] initWithData:[self xorWihData:data] encoding:NSUTF8StringEncoding];
                if ([self.delegate respondsToSelector:@selector(socketManager:didReadString:type:)]) {
                    [self.delegate socketManager:self didReadString:string type:type];
                }
                
            } else {
                break;
            }
        }
        
    });
}

// 获取buffer 中的消息实际数据
- (NSData *)subdataFromBufferWithLength:(NSInteger)length {
    if (self.buffer.length  >= length) {
        
        // 获取实际消息数据
        NSData *data = [self.buffer subdataWithRange:NSMakeRange(0, length)];
        // 把已经解析的数据从buffer 中移除
        self.buffer = [[self.buffer subdataWithRange:NSMakeRange(length, self.buffer.length - length)] mutableCopy];
        return [data subdataWithRange:NSMakeRange(12, length - 12)];
    }
    return nil;
}

// 按位异或解密
- (NSData *)xorWihData:(NSData *)data {
    Byte *Bytearray = (Byte *)[data bytes];
    for (int i = 0; i < data.length; i++) {
        Bytearray[i] = (Byte)(Bytearray[i] ^ 0xFF);
    }
    return [NSData dataWithBytes:Bytearray length:data.length];
}


- (MessageType)parseDataTypeWithTypeData:(NSData *)typeData {
    
    NSInteger typeInt = [self bytesToIntWithData:typeData];
    switch (typeInt) {
        case 1024:
            return MessageTypeLogin;
            break;
            
        case 2048:
            return MessageTypePing;
            break;
            
        case 4096:
            return MessageTypeMessage;
            break;
            
            
        case 3072:
            return MessageTypeIq;
            break;
            
        case 8192:
            return MessageTypePresence;
            break;
            
        default:
            return MessageTypePing;
            break;
    }
}

- (NSInteger)bytesToIntWithData:(NSData*)data
{
    Byte *byte = (Byte *)[data bytes];
    NSInteger value = 0;
    for (int i = 0; i < 4; i++) {
        int shift = i * 8;
        value += (byte[i] & 0xff) << shift;
    }
    return value;
}


// 连接状态
- (BOOL)isConnect {
    return self.socket.isConnected;
}

// 断开
- (void)disconnect {
    [self.socket disconnect];
    self.delegateQueue = nil;
    self.sendQueue = nil;
    self.receiveQueue = nil;
}


- (void)reConnect {
    
}


// ping包
- (void)startPing {
    dispatch_async(self.sendQueue, ^{
        [self.socket writeData:self.pingPacket withTimeout:timeOut tag:tag];
    });
}



- (void)connect {
    NSError *error = nil;
    [self.socket connectToHost:Khost onPort:Kport error:&error];
}


- (void)readRceiveData {
    [self.socket readDataWithTimeout:timeOut tag:tag];
}


#pragma mark -
#pragma mark - GCDAsyncSocketDelegate


/// 发送消息成功回调
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
//    NSLog(@"didWriteDataWithTag = %ld", tag);
    
//    NSLog(@"发送消息成功");

}


/// 收到消息回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
//    NSLog(@"didReadData = %@ -- tag = %ld", data, tag);
    
    
    // 调用解包方法
    [self unpackWithData:data];
    
    // 再次主动读取收到的消息
    [self readRceiveData];
}



/// 连接成功调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    if ([self.delegate respondsToSelector:@selector(socketManager:didConnect:port:)]) {
        [self.delegate socketManager:self didConnect:host port:port];
    }
    
    // 读取数据
    [self readRceiveData];
    
//    NSLog(@" Connect 成功 didConnectToHost: port = %@, %zd, status = %zd", host, port, self.socket.isConnected);
}


/// 断开成功调用

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if ([self.delegate respondsToSelector:@selector(socketManager:didDisconnectWithError:)]) {
        [self.delegate socketManager:self didDisconnectWithError:err];
    }
//    NSLog(@" sock 断开,sock = %@, error = %@, status = %zd",sock, err, self.socket.isConnected);
}


- (void)initSocket {

    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    self.socket.IPv4Enabled = true;
    self.socket.IPv6Enabled = true;
    
}






#pragma mark - lazy

- (NSMutableData *)buffer {
    if (!_buffer) {
        _buffer = [NSMutableData data];
    }
    return _buffer;
}

- (NSData *)pingPacket {
    if (!_pingPacket) {
        _pingPacket = [self packetWithData:self.pingData messageType:MessageTypePing];
    }
    
    return _pingPacket;
}

- (NSTimer *)reConnectTimer {
    if (!_reConnectTimer) {
        _reConnectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(reConnect) userInfo:nil repeats:YES];
    }
    return _reConnectTimer;
}


- (NSTimer *)pingTimer {
    if (!_pingTimer) {
        _pingTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(startPing) userInfo:nil repeats:YES];
    }
    return _pingTimer;
}

- (dispatch_queue_t)delegateQueue {
    if (_delegateQueue == nil) {
        _delegateQueue = dispatch_queue_create("delegateQueueName", DISPATCH_QUEUE_SERIAL);
    }
    return _delegateQueue;
}


- (dispatch_queue_t)sendQueue {
    if (_sendQueue == nil) {
        _sendQueue = dispatch_queue_create("sendQueueName", DISPATCH_QUEUE_SERIAL);
    }
    return _sendQueue;
}

- (dispatch_queue_t)receiveQueue {
    if (_receiveQueue == nil) {
        _receiveQueue = dispatch_queue_create("receiveQueueName", DISPATCH_QUEUE_SERIAL);
    }
    return _receiveQueue;
}

@end
