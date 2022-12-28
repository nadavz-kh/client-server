#import "SeTCPClient.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#include <arpa/inet.h>


@interface SeTCPClient()

- (void)sendData:(NSTimer *)timer;

@property (nonatomic) CFSocketRef socket;
@property (nonatomic) CFDataRef addrRef;
@property (nonatomic) NSString *msg;
@property (nonatomic) NSString *addr;
@property (nonatomic) NSUInteger port;

@end

@implementation SeTCPClient

static const double msgTimeInterval = 1.0f;

- (id)init {
    return [self initWithMessage:@"lol" toAddress:@"127.0.0.1" andPort:6666];
}

- (id)initWithMessage:(NSString *)message toAddress:(NSString *)addr andPort:(NSUInteger)port {
    if ((self = [super init])) {
        _msg = message;
        _addr = addr;
        _port = port;
    }
    
    return self;
}

static void onConnect(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    if(data) {
        NSLog(@"Socket connection failed.");
        CFRelease(s);
    }
    else {
        NSLog(@"Socket connection Success.");
    }
}


- (void)connect:(NSError *__autoreleasing *)error {
    self.socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, onConnect, nil);

    if(!self.socket) {
        if(error)
            *error = [NSError errorWithDomain:@"Server" code:2 userInfo:nil];
        return;
    }

    struct sockaddr_in sin = {0};
    sin.sin_family = AF_INET;
    sin.sin_port = htons(_port);
    sin.sin_addr.s_addr = inet_addr(_addr.UTF8String);
    sin.sin_len = sizeof(_addr);
    
    self.addrRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));
    CFSocketError result = CFSocketConnectToAddress(self.socket, self.addrRef, -1);
    
    if(kCFSocketSuccess != result) {
        NSLog(@"client::connect failed to connect socket.");
        if(error)
            *error = [NSError errorWithDomain:@"Server" code:3 userInfo:nil];
    }
    
    if(error)
        *error = nil;
}

- (void)run:(NSError *__autoreleasing *)error {
    [NSTimer scheduledTimerWithTimeInterval:msgTimeInterval
             target:self selector:@selector(sendData:) userInfo:nil repeats:YES];
    CFRunLoopRun();
}

- (void)sendData:(NSTimer *)timer {
    NSLog(@"lol");
    if(!self.socket) {
        NSLog(@"sendData called without valid socket.");
        return;
    }
    
    NSDictionary *dict = [NSMutableDictionary new];
    
    // getting timestamp
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];

    // setting plist dictionary data
    [dict setValue:_msg forKey:@"msg"];
    [dict setValue:dateString forKey:@"time"];
    
    //change dict to plist (as str)
    NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0;
    NSData *plistData =  [NSPropertyListSerialization dataWithPropertyList:dict format:format options:NSPropertyListImmutable error:nil];
    NSString *plistStr = [[NSString alloc] initWithData:plistData encoding:NSUTF8StringEncoding];
    
    //send to server
    CFDataRef dataRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)plistStr.UTF8String, [plistStr length]);
    CFSocketError err = CFSocketSendData(self.socket, self.addrRef, dataRef, 3);
    
    if(kCFSocketSuccess != err)
        NSLog(@"client::sendData failed to send data in socket.");
}



@end
