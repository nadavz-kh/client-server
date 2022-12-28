#import <Foundation/Foundation.h>

@interface SeTCPClient : NSObject

- (id)initWithMessage:(NSString *)message toAddress:(NSString *)addr andPort:(NSUInteger)port;
- (void)connect:(NSError **)error;
- (void)run:(NSError **)error;

@end
