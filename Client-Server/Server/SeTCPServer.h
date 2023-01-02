#import <Foundation/Foundation.h>

@interface SeTCPServer : NSObject

@property (nonatomic) NSUInteger port;

- (id)initWithPort:(NSUInteger)port;
- (void)start;
- (void)stop;


@end
