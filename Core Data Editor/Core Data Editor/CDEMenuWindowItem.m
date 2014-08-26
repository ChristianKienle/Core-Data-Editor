#import "CDEMenuWindowItem.h"
#import "CDEMenuWindowItemView.h"
#import "CDEMenuItem.h"

@implementation CDEMenuWindowItem

#pragma mark Creating
- (id)init {
   self = [self initWithNibName:@"CDEMenuWindowItem" bundle:nil];
   if(self) {
      self.item = nil;
   }
   return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
