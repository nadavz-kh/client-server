#import <Foundation/Foundation.h>
#import "SeTCPClient.h"

int main(int argc, const char * argv[]) {
    if(3 != argc) {
        NSLog(@"too few arguments: <client> <port> \"<message>\"");
        return 0;
    }
    
    NSString *portStr = [NSString stringWithUTF8String:argv[1]];
    NSInteger port = [portStr integerValue];
    NSString *msgStr = [NSString stringWithUTF8String:argv[2]];
    NSString *addr = @"127.0.0.1";
    
    SeTCPClient *client = [[SeTCPClient alloc] initWithMessage:msgStr toAddress:addr andPort:port];
    [client connect:nil];
    [client run:nil];

    return 0;
}
