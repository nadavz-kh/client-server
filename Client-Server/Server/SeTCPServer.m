#import "SeTCPServer.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>


@implementation SeTCPServer

// socket connection w/ client side. create another data source and add to run-loop
//
void socketDataCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    CFSocketContext socketContext;
    memset(&socketContext, 0, sizeof(CFSocketContext));
    int clientfd = *((int *)data);
    socketContext.info = (void *)((long)clientfd);
    // create CFSocket for w/ connected client
    CFSocketRef socket = CFSocketCreateWithNative(kCFAllocatorDefault, clientfd, kCFSocketDataCallBack, clientDataCallback, &socketContext);
    CFSocketDisableCallBacks(socket, kCFSocketWriteCallBack);
    CFRunLoopSourceRef socketRunLoop = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), socketRunLoop, kCFRunLoopCommonModes);
    CFRelease(socket);
    CFRelease(socketRunLoop);
}

// data to/from client
//
void clientDataCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    if (!(callbackType & kCFSocketDataCallBack))  return;
    CFDataRef incomingData = (CFDataRef)data;
    NSLog(@"incoming data: %s", CFDataGetBytePtr(incomingData));
}

- (void)startWithPort:(NSUInteger)port error:(NSError **)error {
     self.socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, socketDataCallback, nil);
    
    if(!self.socket)
        *error = [NSError errorWithDomain:@"Server" code:2 userInfo:nil];
    
    struct sockaddr_in sin = {0};
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET; /* Address family */
    sin.sin_port = htons(port); /* Or a specific port */
    sin.sin_addr.s_addr = INADDR_ANY;
    
    CFDataRef sinData = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));
    if (CFSocketSetAddress(self.socket, sinData)) {
        NSLog(@"CFSocketSetAddress failed");
        *error = [NSError errorWithDomain:@"Server" code:3 userInfo:nil];
    }

    CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), socketsource, kCFRunLoopDefaultMode);

    *error = nil;
}

- (void)stop {
    CFSocketInvalidate(self.socket);
}

@end
