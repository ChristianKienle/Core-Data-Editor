#import "CDEMenuViewController.h"
#import "CDEMenuWindowItem.h"
#import "CDEMenuView.h"

@implementation CDEMenuViewController

#pragma mark Creating
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.menuView = nil;
  }
  
  return self;
}

#pragma mark NSViewController
- (void)loadView {
  [super loadView];
  self.menuView.itemPrototype = [CDEMenuWindowItem new];
}

@end
