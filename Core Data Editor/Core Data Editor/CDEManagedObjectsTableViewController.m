#import "CDEManagedObjectsTableViewController.h"
#import "CDEManagedObjectsTableViewAttributeHelper.h"
#import "CDEManagedObjectsRequest.h"

#import "BFViewController.h"

@interface CDEManagedObjectsTableViewController () <BFViewController>

@end

@implementation CDEManagedObjectsTableViewController

#pragma mark - Creating
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   return [self init];
}

- (instancetype)init {
   self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
   if(self) {
      self.request = nil;
   }
   return self;
}

#pragma mark - NSViewController
- (void)loadView {
   [super loadView];
}


-(void)viewWillAppear: (BOOL)animated
{
  NSLog(@"%@ - viewWillAppear: %i", self.title, animated);
}

-(void)viewDidAppear: (BOOL)animated
{
  NSLog(@"%@ - viewDidAppear: %i", self.title, animated);
}

-(void)viewWillDisappear: (BOOL)animated
{
  NSLog(@"%@ - viewWillDisappear: %i", self.title, animated);
}

-(void)viewDidDisappear: (BOOL)animated
{
  NSLog(@"%@ - viewDidDisappear: %i", self.title, animated);
}


@end
