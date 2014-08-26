#import "CMKViewController.h"

@implementation CMKViewController

#pragma mark Creating
- (id)init {
   self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
   if(self) {
   }
   return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

@end
