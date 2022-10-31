//
//  FLEXUnifiedLogger.m
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import "FLEXUnifiedLogger.h"
#import "FLEXUnifiedLogMessage.h"
#import "FLEXUnifiedLogViewController.h"
#import "FLEXManager.h"

@interface FLEXUnifiedLogger ()

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation FLEXUnifiedLogger

- (nonnull id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        NSString *queueName = [NSString stringWithFormat:@"com.flex.unified-logger.%@", name];
        const char *ptr = [queueName cStringUsingEncoding:NSUTF8StringEncoding];
        _queue = dispatch_queue_create(ptr, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)debug:(NSString* )text {
    FLEXUnifiedLogMessage *logMessage = [FLEXUnifiedLogMessage logMessageFromMessage:text logLevel:FLEXUnifiedLogLevelDebug];
    
    [self addLogMessage:logMessage];
    
    NSArray *updateLogMessages = [[NSArray alloc] initWithObjects:logMessage, nil];
    [self setNeedsUpdateMessages:updateLogMessages];
}

- (void)info:(NSString* )text {
    FLEXUnifiedLogMessage *logMessage = [FLEXUnifiedLogMessage logMessageFromMessage:text logLevel:FLEXUnifiedLogLevelInfo];
    
    [self addLogMessage:logMessage];
    
    NSArray *updateLogMessages = [[NSArray alloc] initWithObjects:logMessage, nil];
    [self setNeedsUpdateMessages:updateLogMessages];
}

- (void)warning:(NSString* )text {
    FLEXUnifiedLogMessage *logMessage = [FLEXUnifiedLogMessage logMessageFromMessage:text logLevel:FLEXUnifiedLogLevelWarning];
    
    [self addLogMessage:logMessage];
    
    NSArray *updateLogMessages = [[NSArray alloc] initWithObjects:logMessage, nil];
    [self setNeedsUpdateMessages:updateLogMessages];
}

- (void)error:(NSString* )text {
    FLEXUnifiedLogMessage *logMessage = [FLEXUnifiedLogMessage logMessageFromMessage:text logLevel:FLEXUnifiedLogLevelError];
    
    [self addLogMessage:logMessage];
    
    NSArray *updateLogMessages = [[NSArray alloc] initWithObjects:logMessage, nil];
    [self setNeedsUpdateMessages:updateLogMessages];
}

- (void)critical:(NSString* )text {
    FLEXUnifiedLogMessage *logMessage = [FLEXUnifiedLogMessage logMessageFromMessage:text logLevel:FLEXUnifiedLogLevelCritical];
    
    [self addLogMessage:logMessage];
    
    NSArray *updateLogMessages = [[NSArray alloc] initWithObjects:logMessage, nil];
    [self setNeedsUpdateMessages:updateLogMessages];
}

#pragma mark - Private


- (void)addLogMessage:(FLEXUnifiedLogMessage*)logMessage {
    dispatch_sync(_queue, ^{
        [FLEXManager.sharedManager.unifiedLogMessages addObject:logMessage];
    });
}

- (void)setNeedsUpdateMessages:(NSArray<FLEXUnifiedLogMessage *>*)logMessages {
    dispatch_async(dispatch_get_main_queue(), ^() {
        UIViewController *topViewController = [self topViewController];
        
          if ([topViewController isKindOfClass:[FLEXUnifiedLogViewController class]]) {
              FLEXUnifiedLogViewController *unifiedLogViewController = (FLEXUnifiedLogViewController*)topViewController;
              dispatch_sync(loggerBackgroundQueue, ^{
                  unifiedLogViewController.updateHandler(logMessages);
              });
          }
    });
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}
@end
