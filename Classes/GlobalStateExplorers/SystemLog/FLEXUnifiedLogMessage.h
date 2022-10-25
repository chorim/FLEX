//
//  FLEXUnifiedLogMessage.h
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import <Foundation/Foundation.h>
#import <OSLog/OSLog.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FLEXUnifiedLogLevel) {
    FLEXUnifiedLogLevelTrace,
    FLEXUnifiedLogLevelDebug,
    FLEXUnifiedLogLevelInfo,
    FLEXUnifiedLogLevelNotice,
    FLEXUnifiedLogLevelWarning,
    FLEXUnifiedLogLevelError,
    FLEXUnifiedLogLevelCritical
};

@interface FLEXUnifiedLogMessage : NSObject

+ (instancetype)logMessageFromDate:(NSDate *)date text:(NSString *)text;

@property (nonatomic, readonly, nullable) NSString *sender;

@property (nonatomic) FLEXUnifiedLogLevel *logLevel;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSString *messageText;
@property (nonatomic, readonly) long long messageId;

@end

NS_ASSUME_NONNULL_END
