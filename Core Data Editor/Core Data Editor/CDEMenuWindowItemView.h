#import <Cocoa/Cocoa.h>

@class CDEMenuWindowItemBadgeView;
@class CDEMenuItem;
@interface CDEMenuWindowItemView : NSView

#pragma mark Properties
@property (nonatomic, assign) id target;
@property SEL action;
@property (nonatomic, retain) CDEMenuItem *item;
@property (nonatomic, assign) IBOutlet CDEMenuWindowItemBadgeView *badgeView;

@end
