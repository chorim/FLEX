//
//  FLEXUnifiedLoggerViewController.m
//  
//
//  Created by chorim.i on 2022/10/25.
//

#import "FLEXUnifiedLogViewController.h"
#import "FLEXUnifiedLogMessage.h"
#import "FLEXASLLogController.h"
#import "FLEXOSLogController.h"
#import "FLEXUnifiedLogCell.h"
#import "FLEXMutableListSection.h"
#import "FLEXUtility.h"
#import "FLEXColor.h"
#import "FLEXResources.h"
#import "UIBarButtonItem+FLEX.h"
#import "NSUserDefaults+FLEX.h"
#import "flex_fishhook.h"
#import <dlfcn.h>

@interface FLEXUnifiedLogViewController ()

@property (nonatomic, readonly) FLEXMutableListSection<FLEXUnifiedLogMessage *> *logMessages;
@property (nonatomic, readonly) id<FLEXLogController> logController;

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
  
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.title = @"Waiting for Logs...";
  
  UIBarButtonItem *scrollDownItem = [UIBarButtonItem flex_itemWithImage:FLEXResources.scrollToBottomIcon
                                                                 target:self
                                                                 action:@selector(scrollToLastRow)];
  
  UIBarButtonItem *settingsItem = [UIBarButtonItem flex_itemWithImage:FLEXResources.gearIcon
                                                               target:self
                                                               action:@selector(showLogSettings)];
  
  [self addToolbarItems:@[scrollDownItem, settingsItem]];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
//  [self.logController startMonitoring];
}

- (NSArray<FLEXTableViewSection *> *)makeSections { weakify(self)
  _logMessages = [FLEXMutableListSection list:@[]
                            cellConfiguration:^(FLEXUnifiedLogCell *cell,
                                                FLEXUnifiedLogMessage *message,
                                                NSInteger row) {
    strongify(self)
    
    cell.logMessage = message;
    
    if (row % 2 == 0) {
      cell.backgroundColor = FLEXColor.primaryBackgroundColor;
    } else {
      cell.backgroundColor = FLEXColor.secondaryBackgroundColor;
    }
  } filterMatcher:^BOOL(NSString *filterText, FLEXUnifiedLogMessage *message) {
    NSString *displayedText = [FLEXUnifiedLogCell displayedTextForLogMessage:message];
    return [displayedText localizedCaseInsensitiveContainsString:filterText];
  }];
  
  self.logMessages.cellRegistrationMapping = @{
    kFLEXUnifiedLogCellIdentifier: [FLEXUnifiedLogCell class]
  };
  
  return @[self.logMessages];
}

- (NSArray<FLEXTableViewSection *> *)nonemptySections {
    return @[self.logMessages];
}

#pragma mark - Private
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
    UIPasteboard.generalPasteboard.string = self.logMessages.filteredList[indexPath.row].messageText ?: @"";
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
      UIPasteboard.generalPasteboard.string = self.logMessages.filteredList[indexPath.row].messageText ?: @"";
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
  FLEXUnifiedLogMessage *logMessage = self.logMessages.filteredList[indexPath.row];

  return [FLEXUnifiedLogCell preferredHeightForLogMessage:logMessage
                                                  inWidth:self.tableView.bounds.size.width];
}

@end
