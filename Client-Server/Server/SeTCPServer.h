#import <Foundation/Foundation.h>

@interface SeTCPServer : NSObject <NSStreamDelegate>

@property (nonatomic) CFSocketRef socket;
@property (nonatomic) NSInputStream *inputStream;

- (void)startWithPort:(NSUInteger) port error:(NSError **)error;
- (void)stop;

@end
