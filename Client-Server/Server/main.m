#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

#import "SeTCPServer.h"

int main(int argc, const char * argv[]) {
    SeTCPServer *server = [SeTCPServer new];
    NSError *err = nil;
    
    [server startWithPort:6666 error:&err];
    
    CFRunLoopRun();
    
    return 0;
}

