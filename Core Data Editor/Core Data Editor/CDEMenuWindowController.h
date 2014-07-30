#import <Foundation/Foundation.h>

@class CDEMenuViewController;
@interface CDEMenuWindowController : NSObject

#pragma mark Creating
- (id)initWithMenuItems:(NSArray *)initMenuItems size:(NSSize)menuViewSize;

#pragma mark Working with the Window
- (void)dismissWindowAndDetach;
- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge;

@end
