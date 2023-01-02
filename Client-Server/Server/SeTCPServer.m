#import "SeTCPServer.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>

@interface SeTCPServer()

@property (nonatomic) CFSocketRef socket;
@property (nonatomic) NSInputStream *inputStream;

@end

@implementation SeTCPServer

- (id)init {
    return [self initWithPort:6666];
}

- (id)initWithPort:(NSUInteger)port {
    if(([super init])) {
        _port = port;
    }

    return self;
}

- (void)start {
    self.socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, serverConnectCallback, nil);
   
    if(!self.socket) {
        NSLog(@"CFSocketCreate failed");
        return;
    }

    struct sockaddr_in sin = {0};
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET; /* Address family */
    sin.sin_port = htons(self.port); /* Or a specific port */
    sin.sin_addr.s_addr = INADDR_ANY;

    CFDataRef sinData = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));
    if (CFSocketSetAddress(self.socket, sinData)) {
        NSLog(@"CFSocketSetAddress failed");
        return;
    }

    CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), socketsource, kCFRunLoopDefaultMode);
    CFRunLoopRun();
}

// socket connection w/ client side. create another data source and add to run-loop
void serverConnectCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
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
void clientDataCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    if (!(callbackType & kCFSocketDataCallBack))  return;
    NSData *incomingData = (__bridge NSData *)data;

    if (incomingData.bytes) {
        NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0;
        NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:incomingData options:NSPropertyListImmutable format:&format error:nil];
        
        NSString *msg = [plist objectForKey:@"msg"];
        NSString *timestamp = [plist objectForKey:@"time"];
        
        NSLog(@"%@ ::: %@", timestamp, msg);
    }
}

- (void)stop {
    CFSocketInvalidate(self.socket);
}

@end
