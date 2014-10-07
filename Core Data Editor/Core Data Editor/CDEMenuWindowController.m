#import "CDEMenuWindowController.h"
#import "CDEMenuView.h"
#import "CDEMenuWindowItem.h"
#import "CDEMenuViewController.h"

@interface CDEMenuWindowController ()

#pragma mark Properties
@property (nonatomic, retain) NSPopover *popover;
@property (nonatomic, retain) CDEMenuViewController *menuViewController;

@end

@implementation CDEMenuWindowController

#pragma mark Creating
- (id)initWithMenuItems:(NSArray *)initMenuItems size:(NSSize)menuViewSize {
  self = [super init];
  if(self) {
    self.menuViewController = [[CDEMenuViewController alloc] initWithNibName:@"CDEMenuViewController" bundle:nil];
    [self.menuViewController view];
    self.menuViewController.menuView.items = initMenuItems;
    [self.menuViewController.menuView sizeToFit];
    self.popover = [NSPopover new];
    self.popover.animates = NO; // animates => performance problems
    [self.popover setContentViewController:self.menuViewController];
    [self.popover setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    [self.popover setBehavior:NSPopoverBehaviorTransient];
  }
  return self;
}

- (id)init {
  return [self initWithMenuItems:[NSArray array] size:NSMakeSize(100.0, 100.0)];
}

#pragma mark Working with the Window
- (void)dismissWindowAndDetach {
  [self.popover performClose:self];
}

- (void)showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge {
  [self.popover showRelativeToRect:positioningRect ofView:positioningView preferredEdge:preferredEdge];
}

@end
