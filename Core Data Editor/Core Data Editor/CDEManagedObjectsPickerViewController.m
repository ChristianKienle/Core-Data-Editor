#import "CDEManagedObjectsPickerViewController.h"
#import "CDEManagedObjectsViewController.h"
#import "CDEManagedObjectsPickerDataCoordinator.h"
#import "CDEManagedObjectsRequest.h"

@interface CDEManagedObjectsPickerViewController ()

#pragma mark - Properties
@property (nonatomic, strong) CDEManagedObjectsViewController *managedObjectsViewController;

@end

@implementation CDEManagedObjectsPickerViewController

#pragma mark - Creating
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.managedObjectsViewController = [CDEManagedObjectsViewController new];
        [self.managedObjectsViewController view];
        self.managedObjectsViewController.bottomBarVisible = NO;
    }
    
    return self;
}

#pragma mark - NSViewController
- (void)loadView {
    [super loadView];
    self.managedObjectsViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.managedObjectsViewController.view];
}


#pragma mark - Displaying Stuff
- (void)setEntityDescription:(NSEntityDescription *)entityDescription
      selectedManagedObjects:(id)selectedManagedObjects
        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
     allowsMultipleSelection:(BOOL)allowsMultipleSelection {
    NSParameterAssert((entityDescription != nil && managedObjectContext != nil) ||
                      (entityDescription == nil && managedObjectContext == nil));
    
    if(entityDescription == nil) {
        [self.managedObjectsViewController setRequest:nil];
    } else {
        CDEManagedObjectsRequest *request = [[CDEManagedObjectsRequest alloc] initWithEntityDescription:entityDescription
                                                                                   managedObjectContext:managedObjectContext];
        NSTableView *tableView = self.managedObjectsViewController.tableView;
        CDEManagedObjectsPickerDataCoordinator *dataCoordinator = [[CDEManagedObjectsPickerDataCoordinator alloc] initWithManagedObjectsRequest:request
                                                                                                                                      tableView:tableView
                                                                                                                   managedObjectsViewController:self.managedObjectsViewController
                                                                                                                         selectedManagedObjects:selectedManagedObjects
                                                                                                                        allowsMultipleSelection:allowsMultipleSelection];
        [self.managedObjectsViewController setRequest:request
                                      dataCoordinator:dataCoordinator];
    }
}

#pragma mark - Properties
- (NSSet *)selectedManagedObjects {
    CDEManagedObjectsPickerDataCoordinator *dataCoordinator = (CDEManagedObjectsPickerDataCoordinator *)self.managedObjectsViewController.dataCoordinator;
    return dataCoordinator.selectedManagedObjects;
}

#pragma mark - Actions
- (IBAction)takeIsSelectedValueFromSender:(id)sender {
    CDEManagedObjectsPickerDataCoordinator *dataCoordinator = (CDEManagedObjectsPickerDataCoordinator *)self.managedObjectsViewController.dataCoordinator;
    [dataCoordinator takeIsSelectedValueFromSender:sender];
}

@end
