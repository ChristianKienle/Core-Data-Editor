#import "CDEMenuWindowItem.h"
#import "CDEMenuWindowItemView.h"
#import "CDEMenuItem.h"

@implementation CDEMenuWindowItem

#pragma mark Creating
<<<<<<< HEAD
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
=======
- (id)init {
   self = [self initWithNibName:@"CDEMenuWindowItem" bundle:nil];
>>>>>>> 65ba89d7421433954f4d462d9419443797f8901d
   if(self) {
      self.item = nil;
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


#pragma mark Properties
- (void)setItem:(CDEMenuItem *)newItem {
   _item = newItem;
   CDEMenuWindowItemView *itemView = (CDEMenuWindowItemView *)self.view;
   itemView.target = self.item.target;
   itemView.action = self.item.action;
   itemView.item = self.item;
}

@end
