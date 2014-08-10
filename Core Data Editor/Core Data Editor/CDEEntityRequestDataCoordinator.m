#import "CDEEntityRequestDataCoordinator.h"
#import "CDEManagedObjectsRequest.h"
#import "CDEAutosaveInformation.h"
#import "CDEEntityAutosaveInformation.h"
#import "CDEEntityAutosaveInformationItem.h"
#import "CDEManagedObjectsViewController.h"
#import "CDERequestDataCoordinator_Subclass.h"

@interface CDEEntityRequestDataCoordinator ()

#pragma mark - Properties
@property (nonatomic, strong) NSArrayController *arrayController;

@end

@implementation CDEEntityRequestDataCoordinator

- (NSInteger)numberOfObjects {
    return [[self.arrayController arrangedObjects] count];
}

// Returning nil is okay
- (id)objectValueForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSUInteger)index {
    NSManagedObject *object = [self.arrayController arrangedObjects][index];
    id objectValue = [object valueForKey:tableColumn.identifier];
    return objectValue;
}

- (NSManagedObject *)managedObjectAtIndex:(NSUInteger)index {
    NSManagedObject *object = [self.arrayController arrangedObjects][index];
    return object;
}

- (NSUInteger)indexOfManagedObject:(NSManagedObject *)managedObject {
    NSParameterAssert(managedObject);
    return [[self.arrayController arrangedObjects] indexOfObject:managedObject];
}

- (NSDictionary *)tableColumnsByIdentifier {
    NSMutableDictionary *result = [NSMutableDictionary new];
    for(NSTableColumn *column in self.tableColumns) {
        result[column.identifier] = column;
    }
    return result;
}

- (void)prepare {
    // Adjust columns
    CDEAutosaveInformation *autosaveInformation = self.managedObjectsViewController.autosaveInformation;
    if(autosaveInformation != nil) {
        // Get the information for the entity
        NSString *entityName = self.request.entityDescription.name;
        if(entityName != nil) {
            CDEEntityAutosaveInformation *entityInformation = [autosaveInformation informationForEntityNamed:entityName];
            if(entityInformation != nil) {
                NSDictionary *tableColumnsByIdentifier = [self tableColumnsByIdentifier];
                NSMutableOrderedSet *newColumns = [NSMutableOrderedSet orderedSetWithArray:self.tableColumns];
                NSUInteger designatedIndex = 0;
                for(CDEEntityAutosaveInformationItem *item in entityInformation.items) {
                    NSTableColumn *column = tableColumnsByIdentifier[item.identifier];
                    if(column != nil) {
                        NSUInteger currentIndex = [newColumns indexOfObject:column];
                        if(currentIndex != NSNotFound && newColumns.count > designatedIndex) {
                            [newColumns moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:currentIndex] toIndex:designatedIndex];
                        }
                        column.width = item.width;
                    }
                    designatedIndex++;
                }
                self.tableColumns = newColumns.array;
            }
        }
    }

    // Array Controller
    self.arrayController = [[NSArrayController alloc] initWithContent:nil];
    self.arrayController.entityName = self.request.entityDescription.name;
    self.arrayController.managedObjectContext = self.request.managedObjectContext;
    self.arrayController.selectsInsertedObjects = YES;
    NSFetchRequest *fetchRequest = nil;
    if(self.request.isFetchRequest) {
        fetchRequest = self.request.fetchRequest;
    } else {
        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.request.entityDescription.name];
    }
    fetchRequest.entity = self.request.entityDescription;

    NSError *error = nil;
    BOOL fetched = [self.arrayController fetchWithRequest:fetchRequest merge:NO error:&error];
    if(fetched == NO) {
        NSLog(@"Error: %@", error);
        return;
    }

    [self.tableView bind:NSContentBinding toObject:self.arrayController withKeyPath:@"arrangedObjects" options:nil];
    [self.tableView bind:NSSelectionIndexesBinding toObject:self.arrayController withKeyPath:@"selectionIndexes" options:nil];
    [self.tableView bind:NSSortDescriptorsBinding toObject:self.arrayController withKeyPath:@"sortDescriptors" options:nil];
}

- (void)invalidate {
    [self.tableView unbind:NSContentBinding];
    [self.tableView unbind:NSSelectionIndexesBinding];
    [self.tableView unbind:NSSortDescriptorsBinding];
    self.arrayController = nil;
}

- (NSManagedObject *)createAndAddManagedObject {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:self.request.entityDescription.name inManagedObjectContext:self.request.managedObjectContext];
    [self.arrayController addObject:object];
    return object;
}

- (void)removeManagedObjectAtIndex:(NSUInteger)index {
    [self.arrayController removeObjectAtArrangedObjectIndex:index];
}

- (NSView *)viewForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSInteger)index {
    return [super viewForTableColumn:tableColumn atIndex:index];
}

- (void)didChangeFilterPredicate {
    self.arrayController.filterPredicate = self.filterPredicate;
    NSNotification *notification = [NSNotification notificationWithName:NSTableViewSelectionDidChangeNotification object:self.tableView userInfo:@{}];
    [self.tableView.delegate tableViewSelectionDidChange:notification];
}

- (BOOL)canPerformAdd {
    return YES;
}

- (BOOL)canPerformDelete {
    // Delete only possible if there is a selection
    return (self.tableView.selectedRow != -1);
    return [[self.arrayController selectedObjects] count] > 0;
}

#pragma mark - Autosave
- (void)updateAutosaveInformation:(CDEAutosaveInformation *)autosaveInformation {
    // do nothing by default
}

@end
