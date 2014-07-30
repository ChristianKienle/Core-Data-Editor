#import <Cocoa/Cocoa.h>

@interface CDERelationshipTableCellView : NSTableCellView

// objectValue is instance of CDERelationshipsViewControllerItem

#pragma mark - Properties
@property (nonatomic, assign) NSInteger badgeValue;

#pragma mark - UI
- (void)updateTitle;
- (void)reloadBadgeValue;


@end
