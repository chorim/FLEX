//
//  FLEXUnifiedLoggerViewController.m
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import "FLEXUnifiedLogViewController.h"
#import "FLEXUnifiedLogger.h"
#import "FLEXASLLogController.h"
#import "FLEXOSLogController.h"
#import "FLEXUnifiedLogCell.h"
#import "FLEXMutableListSection.h"
#import "FLEXUtility.h"
#import "FLEXColor.h"
#import "FLEXResources.h"
#import "FLEXManager+Private.h"
#import "UIBarButtonItem+FLEX.h"
#import "NSUserDefaults+FLEX.h"
#import "flex_fishhook.h"
#import <dlfcn.h>

@interface FLEXUnifiedLogViewController ()

@property (nonatomic, readonly) id<FLEXLogController> logController;
@property (nonatomic) FLEXMutableListSection<FLEXUnifiedLogMessage *> *logMessages;

@end

@implementation FLEXUnifiedLogViewController

- (id)init {
    return [super initWithStyle:UITableViewStylePlain];
}

#pragma mark - Overrides
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showsSearchBar = YES;
    self.pinSearchBar = YES;
    
    weakify(self)
    id logHandler = ^(NSArray<FLEXUnifiedLogMessage *> *newMessages) { strongify(self)
        [self handleUpdateWithNewMessages:newMessages];
    };
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"Waiting for Logs...";
    
    _updateHandler = logHandler;
    
    UIBarButtonItem *scrollDownItem = [UIBarButtonItem flex_itemWithImage:FLEXResources.scrollToBottomIcon
                                                                   target:self
                                                                   action:@selector(scrollToLastRow)];
    
    UIBarButtonItem *settingsItem = [UIBarButtonItem flex_itemWithImage:FLEXResources.gearIcon
                                                                 target:self
                                                                 action:@selector(showLogSettings)];
    
    [self addToolbarItems:@[scrollDownItem, settingsItem]];
    
    [self reloadPreviousLogMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = [self.class globalsEntryTitle:FLEXGlobalsRowUnifiedLogger];
}

- (void)reloadPreviousLogMessages {
    if (self.updateHandler && FLEXManager.sharedManager.unifiedLogMessages.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableView *tableView = self.tableView;
            BOOL wasNearBottom = tableView.contentOffset.y >= tableView.contentSize.height - tableView.frame.size.height - 100.0;
            [self reloadData];
            [self scrollToLastRow];
        });
    }
}

- (NSArray<FLEXTableViewSection *> *)makeSections {
    weakify(self)

    NSArray<FLEXUnifiedLogMessage *> *globalLogMessages = [FLEXManager.sharedManager.unifiedLogMessages copy];
  
    _logMessages = [FLEXMutableListSection list:globalLogMessages
                              cellConfiguration:^(FLEXUnifiedLogCell *cell,
                                                  FLEXUnifiedLogMessage *message,
                                                  NSInteger row) {
        strongify(self)
        
        cell.logMessage = message;
        cell.highlightedText = self.filterText;
        
        if (row % 2 == 0) {
            cell.backgroundColor = FLEXColor.primaryBackgroundColor;
        } else {
            cell.backgroundColor = FLEXColor.secondaryBackgroundColor;
        }
    } filterMatcher:^BOOL(NSString *filterText, FLEXUnifiedLogMessage *message) {
        NSString *displayedText = [FLEXUnifiedLogCell displayedTextForLogMessage:message];
        return [displayedText localizedCaseInsensitiveContainsString:filterText];
    }];
    
    _logMessages.cellRegistrationMapping = @{
        kFLEXUnifiedLogCellIdentifier: [FLEXUnifiedLogCell class]
    };
    
    return @[_logMessages];
}

- (NSArray<FLEXTableViewSection *> *)nonemptySections {
    return @[_logMessages];
}

#pragma mark - Private

- (void)handleUpdateWithNewMessages:(NSArray<FLEXUnifiedLogMessage *> *)newMessages {
  dispatch_async(dispatch_get_main_queue(), ^{
    [_logMessages mutate:^(NSMutableArray *list) {
        [list addObjectsFromArray:newMessages];
    }];
    
    if (self.filterText.length) {
        [self updateSearchResults:self.filterText];
    }
    
    UITableView *tableView = self.tableView;
    BOOL wasNearBottom = tableView.contentOffset.y >= tableView.contentSize.height - tableView.frame.size.height - 100.0;
    [self reloadData];
    if (wasNearBottom) {
        [self scrollToLastRow];
    }
  });
}

- (void)scrollToLastRow {
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    if (numberOfRows > 0) {
        NSIndexPath *last = [NSIndexPath indexPathForRow:numberOfRows - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:last
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}

- (void)showLogSettings {
    
}

#pragma mark - Copy on long press
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UIPasteboard.generalPasteboard.string = _logMessages.filteredList[indexPath.row].messageText ?: @"";
    }
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView
contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
                                    point:(CGPoint)point __IOS_AVAILABLE(13.0) {
    weakify(self)
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil
                                                    actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
        UIAction *copy = [UIAction actionWithTitle:@"Copy"
                                             image:nil
                                        identifier:@"Copy"
                                           handler:^(UIAction *action) { strongify(self)
            UIPasteboard.generalPasteboard.string = _logMessages.filteredList[indexPath.row].messageText ?: @"";
        }];
        return [UIMenu menuWithTitle:@""
                               image:nil
                          identifier:nil
                             options:UIMenuOptionsDisplayInline
                            children:@[copy]];
    }
    ];
}

#pragma mark - FLEXGlobalsEntry
+ (nonnull NSString *)globalsEntryTitle:(FLEXGlobalsRow)row {
    return @"🗂 Unified Logger";
}

+ (UIViewController *)globalsEntryViewController:(FLEXGlobalsRow)row {
    return [self new];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLEXUnifiedLogMessage *logMessage = _logMessages.filteredList[indexPath.row];
    
    return [FLEXUnifiedLogCell preferredHeightForLogMessage:logMessage
                                                    inWidth:self.tableView.bounds.size.width];
}

@end
