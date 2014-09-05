#import "CMKViewController.h"

@implementation CMKViewController

#pragma mark Creating
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if(self) {
   }
   return self;
}

- (id)init {
   return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

@end
