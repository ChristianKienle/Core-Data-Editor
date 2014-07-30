#import "CDEEntityRequestDataCoordinator.h"

@interface CDEManagedObjectsPickerDataCoordinator : CDEEntityRequestDataCoordinator
#pragma mark - Creating 
- (id)initWithManagedObjectsRequest:(CDEManagedObjectsRequest *)request
                          tableView:(NSTableView *)tableView
       managedObjectsViewController:(CDEManagedObjectsViewController *)managedObjectsViewController
             selectedManagedObjects:(id)selectedManagedObjects // NSSet or NSOrderedSet
            allowsMultipleSelection:(BOOL)allowsMultipleSelection;

#pragma mark - Properties
@property (nonatomic, copy, readonly) id selectedManagedObjects;

#pragma mark - Actions
- (IBAction)takeIsSelectedValueFromSender:(id)sender;

@end
