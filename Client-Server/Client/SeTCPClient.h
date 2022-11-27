#import <Foundation/Foundation.h>

@interface SeTCPClient : NSObject

- (void)connectToAddress:(NSString *)addr port:(NSUInteger)port error:(NSError **)error;
- (void)sendData:(NSString *)data error:(NSError **)error;

@end
