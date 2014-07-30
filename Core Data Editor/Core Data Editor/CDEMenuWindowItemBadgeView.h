#import <Cocoa/Cocoa.h>

@interface CDEMenuWindowItemBadgeView : NSView

#pragma mark Properties
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, readwrite, copy) NSString *badgeValue;
@property (nonatomic, readwrite, assign) BOOL showsBadge;

@end
