//
//  FLEXUnifiedLogCell.h
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import "FLEXTableViewCell.h"

@class FLEXUnifiedLogMessage;

extern NSString *const kFLEXUnifiedLogCellIdentifier;

@interface FLEXUnifiedLogCell : FLEXTableViewCell

@property (nonatomic) FLEXUnifiedLogMessage *logMessage;
@property (nonatomic, copy) NSString *highlightedText;

+ (NSString *)displayedTextForLogMessage:(FLEXUnifiedLogMessage*) logMessage;
+ (CGFloat)preferredHeightForLogMessage:(FLEXUnifiedLogMessage*) logMessage inWidth:(CGFloat)width;

@end

