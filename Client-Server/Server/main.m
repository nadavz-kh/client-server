#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

#import "SeTCPServer.h"



int main(int argc, const char * argv[]) {
    if(2 != argc) {
        NSLog(@"too few arguments: <server> <port>");
    }
    
    NSString *portStr = [NSString stringWithUTF8String:argv[1]];
    NSInteger port = [portStr integerValue];
    
    SeTCPServer *server = [[SeTCPServer alloc] initWithPort:port];
    [server start];

    return 0;
}

