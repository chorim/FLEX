//
//  FLEXUnifiedLogger.h
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import <Foundation/Foundation.h>

#define loggerBackgroundQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface FLEXUnifiedLogger : NSObject

//+ (instancetype)initWithName:(NSString *)name;
- (nonnull id)initWithName:(NSString *)name;

- (void)debug:(NSString* )text;
- (void)info:(NSString* )text;
- (void)warning:(NSString* )text;
- (void)error:(NSString* )text;
- (void)critical:(NSString* )text;
@end
