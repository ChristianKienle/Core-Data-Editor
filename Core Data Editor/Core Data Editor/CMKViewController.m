#import "CMKViewController.h"

@implementation CMKViewController

#pragma mark Creating
<<<<<<< HEAD
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
=======
- (id)init {
   self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
>>>>>>> 65ba89d7421433954f4d462d9419443797f8901d
   if(self) {
   }
   return self;
}

<<<<<<< HEAD
- (id)init {
   return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
=======
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
>>>>>>> 65ba89d7421433954f4d462d9419443797f8901d
}

@end
