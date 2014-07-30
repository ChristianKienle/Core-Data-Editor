#import <Cocoa/Cocoa.h>

@class CDEMenuWindowItem;
@interface CDEMenuView : NSView

#pragma mark Properties
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, retain) CDEMenuWindowItem *itemPrototype;

#pragma mark Resizing
- (NSSize)minimumSize;
- (void)sizeToFit;

@end
