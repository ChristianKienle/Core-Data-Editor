#import <Cocoa/Cocoa.h>

@interface CDEEntityTableCellView : NSTableCellView

#pragma mark - Properties
@property (nonatomic, assign) NSInteger badgeValue;
@property (nonatomic, weak) IBOutlet NSButton *badgeButton;

@end
