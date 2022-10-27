//
//  FLEXUnifiedLogMessage.h
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FLEXUnifiedLogLevel) {
    FLEXUnifiedLogLevelDebug,
    FLEXUnifiedLogLevelInfo,
    FLEXUnifiedLogLevelWarning,
    FLEXUnifiedLogLevelError,
    FLEXUnifiedLogLevelCritical
};

@interface FLEXUnifiedLogMessage : NSObject

+ (instancetype)logMessageFromDate:(NSDate *)date text:(NSString *)text;
+ (instancetype)logMessageFromMessage:(NSString *)text logLevel:(FLEXUnifiedLogLevel)logLevel;

@property (nonatomic) FLEXUnifiedLogLevel *logLevel;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSString *messageText;
@property (nonatomic, readonly) NSUUID *messageId;

@end

NS_ASSUME_NONNULL_END
