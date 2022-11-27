#import <Foundation/Foundation.h>
#import "SeTCPClient.h"

int main(int argc, const char * argv[]) {
    
    SeTCPClient *client = [SeTCPClient new];
    NSError *err = nil;
    
    [client connectToAddress:@"127.0.0.1" port:6666 error:&err];
    if(err)
        return -2;
    
    
    [NSThread sleepForTimeInterval:5.0f];
    
    
    [client sendData:@"lol1" error:&err];
    if(err)
        return -3;

    
    return 0;
}
