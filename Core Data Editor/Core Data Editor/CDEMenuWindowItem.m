#import "CDEMenuWindowItem.h"
#import "CDEMenuWindowItemView.h"
#import "CDEMenuItem.h"

@implementation CDEMenuWindowItem

#pragma mark Creating
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if(self) {
      self.item = nil;
   }
   return self;
}

- (id)init {
   return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
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
