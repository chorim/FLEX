//
//  FLEXUnifiedLogMessage.m
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import "FLEXUnifiedLogMessage.h"

@implementation FLEXUnifiedLogMessage

+ (instancetype)logMessageFromDate:(NSDate *)date text:(NSString *)text {
    return [[self alloc] initWithDate:date sender:nil text:text messageId:0];
}

- (id)initWithDate:(NSDate *)date sender:(NSString *)sender text:(NSString *)text messageId:(long long)identifier {
    self = [super init];
    if (self) {
        _date = date;
        _sender = sender;
        _messageText = text;
        _messageId = identifier;
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
