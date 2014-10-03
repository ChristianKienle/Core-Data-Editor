#import "CDEManagedObjectsTableViewController.h"
#import "CDEManagedObjectsTableViewAttributeHelper.h"
#import "CDEManagedObjectsRequest.h"

#import "BFViewController.h"

@interface CDEManagedObjectsTableViewController () <BFViewController>

- (instancetype)init; // NS_DESIGNATED_INITIALIZER;
@end

@implementation CDEManagedObjectsTableViewController

#pragma mark - Creating
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.request = nil;
    }
    return self;
}

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

#pragma mark - NSViewController
- (void)loadView {
   [super loadView];
}


@end
