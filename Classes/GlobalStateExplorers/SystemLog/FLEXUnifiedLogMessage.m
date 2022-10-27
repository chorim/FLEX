//
//  FLEXUnifiedLogMessage.m
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import "FLEXUnifiedLogMessage.h"

@implementation FLEXUnifiedLogMessage

+ (instancetype)logMessageFromDate:(NSDate *)date text:(NSString *)text {
    NSUUID *uuid = [[NSUUID UUID] init];
    return [[self alloc] initWithDate:date
                                 text:text
                                 uuid:uuid
                             logLevel:FLEXUnifiedLogLevelDebug];
}

+ (instancetype)logMessageFromMessage:(NSString *)text logLevel:(FLEXUnifiedLogLevel)logLevel {
    NSDate *now = [NSDate date];
    NSUUID *uuid = [[NSUUID UUID] init];
    return [[self alloc] initWithDate:now
                                 text:text
                                 uuid:uuid
                             logLevel:logLevel];
}

- (id)initWithDate:(NSDate *)date text:(NSString *)text uuid:(NSUUID*)uuid logLevel:(FLEXUnifiedLogLevel)logLevel {
    self = [super init];
    if (self) {
        _date = date;
        _messageText = text;
        _messageId = uuid;
        _logLevel = logLevel;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        if (self.messageId) {
            return self.messageId == [object messageId];
        } else {
            return [self.messageText isEqual:[object messageText]] &&
            [self.date isEqualToDate:[object date]];
        }
    }
    
    return NO;
}

- (NSUInteger)hash {
    return (NSUInteger)self.messageId;
}

- (NSString *)description {
    NSString *escaped = [self.messageText stringByReplacingOccurrencesOfString:@"\n"
                                                                    withString:@"\\n"];
    return [NSString stringWithFormat:@"(%@) %@",
            @(self.messageText.length),
            escaped];
}
@end
