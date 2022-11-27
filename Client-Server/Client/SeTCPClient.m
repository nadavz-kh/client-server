#import "SeTCPClient.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#include <arpa/inet.h>


@interface SeTCPClient()

@property (nonatomic) CFSocketRef socket;
@property (nonatomic) CFDataRef addrRef;

@end

@implementation SeTCPClient

static void onConnect(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    if(data) {
        NSLog(@"Socket connection failed.");
        CFRelease(s);
    }
    else {
        NSLog(@"Socket connection Success.");
    }
}

- (void)connectToAddress:(NSString *)addr port:(NSUInteger)port error:(NSError **)error {
    self.socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, onConnect, nil);

    if(!self.socket)
       *error = [NSError errorWithDomain:@"Server" code:2 userInfo:nil];

    struct sockaddr_in sin = {0};
    sin.sin_family = AF_INET; /* Address family */
    sin.sin_port = htons(port); /* Or a specific port */
    sin.sin_addr.s_addr = inet_addr(addr.UTF8String);
    sin.sin_len = sizeof(addr);
    
    self.addrRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));
    CFSocketError result = CFSocketConnectToAddress(self.socket, self.addrRef, -1);
}

- (void)sendData:(NSString *)data error:(NSError **)error {
    CFDataRef dataRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)data.UTF8String, [data length]);
    CFSocketError err = CFSocketSendData(self.socket, self.addrRef, dataRef, 3);

    if (err == kCFSocketSuccess) {
        NSLog(@"send success");
    }else {
        NSLog(@"send fail");
    }
}

@end
