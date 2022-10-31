//
//  FLEXUnifiedLoggerViewController.h
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import "FLEXFilteringTableViewController.h"
#import "FLEXGlobalsEntry.h"
#import "FLEXUnifiedLogMessage.h"

@interface FLEXUnifiedLogViewController : FLEXFilteringTableViewController<FLEXGlobalsEntry>

@property (nonatomic) void (^updateHandler)(NSArray<FLEXUnifiedLogMessage *> *);

@end
