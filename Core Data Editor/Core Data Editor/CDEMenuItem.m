#import "CDEMenuItem.h"

@interface CDEMenuItem ()

#pragma mark Properties
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, assign) SEL action;
@property (nonatomic, readwrite, assign) id target;
@property (nonatomic, readwrite, retain) id representedObject;
@property (nonatomic, readwrite, copy) NSString *badgeValue;
@property (nonatomic, readwrite, assign) BOOL showsBadge;

@end

@implementation CDEMenuItem

#pragma mark Creating
- (id)initWithTitle:(NSString *)initTitle target:(id)initTarget action:(SEL)initAction representedObject:(id)initRepresentedObject badgeValue:(NSString *)initBadgeValue showsBadge:(BOOL)initShowsBadge {
   self = [super init];
   if(self) {
      self.title = initTitle;
      self.target = initTarget;
      self.action = initAction;
      self.representedObject = initRepresentedObject;
      self.badgeValue = initBadgeValue;
      self.showsBadge = initShowsBadge;
   }
   return self;
}

- (id)init {
   return [self initWithTitle:[NSString string] target:nil action:nil representedObject:nil badgeValue:[NSString string] showsBadge:NO];
}

@end
