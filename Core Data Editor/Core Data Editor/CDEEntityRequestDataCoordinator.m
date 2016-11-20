#import "CDEEntityRequestDataCoordinator.h"
#import "CDEManagedObjectsRequest.h"
#import "CDEAutosaveInformation.h"
#import "CDEEntityAutosaveInformation.h"
#import "CDEEntityAutosaveInformationItem.h"
#import "CDEManagedObjectsViewController.h"
#import "CDERequestDataCoordinator_Subclass.h"
#import "FilteringArray.h"

@interface CDEEntityRequestDataCoordinator ()

#pragma mark - Properties
@property (strong) FilteringArray<NSManagedObject*> *filteringArray;

@end

@implementation CDEEntityRequestDataCoordinator

- (NSInteger)numberOfObjects {
  return self.filteringArray == nil ? 0 : self.filteringArray.count;
}

// Returning nil is okay
- (id)objectValueForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSUInteger)index {
  NSManagedObject *object = [self managedObjectAtIndex: index];
  id objectValue = [object valueForKey:tableColumn.identifier];
  return objectValue;
}

- (NSManagedObject *)managedObjectAtIndex:(NSUInteger)index {
  NSManagedObject *object = [self.filteringArray objectAtIndex:index];
  return object;
}

- (NSUInteger)indexOfManagedObject:(NSManagedObject *)managedObject {
  NSParameterAssert(managedObject);
  return [self.filteringArray indexOfObject:managedObject];
}

- (NSDictionary *)tableColumnsByIdentifier {
  NSMutableDictionary *result = [NSMutableDictionary new];
  for(NSTableColumn *column in self.tableColumns) {
    result[column.identifier] = column;
  }
  return result;
}

- (void)dealloc
{
  NSLog(@"");
}

- (void)prepare {
  NSAssert(self.request.isEntityRequest, @"");
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
  
  NSError *fetchError = nil;
  NSString *entityName = self.request.entityDescription.name;
  NSFetchRequest<NSManagedObject *> *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
  NSArray *objects = [self.request.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
  if(objects == nil) {
    NSLog(@"error: %@", fetchError);
    return;
  }
  self.filteringArray = [FilteringArray new];
  [self.filteringArray addObjectsFromArray:objects];
  [self.tableView reloadData];
}

- (void)invalidate {
}

- (NSManagedObject *)createAndAddManagedObject {
  NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:self.request.entityDescription.name inManagedObjectContext:self.request.managedObjectContext];
  [self addObject:object];
  return object;
}

- (void)removeSelectedManagedObjects {
  NSIndexSet *indexes = [self indexesOfSelectedManagedObjects];
  NSArray<NSManagedObject*>* objects = [self.filteringArray objectsAtIndexes:indexes];
  [self.filteringArray removeObjectsAtIndexes:indexes];
  for(NSManagedObject *object in objects) {
    [self.request.managedObjectContext deleteObject:object];
  }
  [self.tableView reloadData];

}

- (void)removeManagedObjectAtIndex:(NSUInteger)index {
  [self.filteringArray removeObjectAtIndex:index];
}

- (NSView *)viewForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSInteger)index {
  return [super viewForTableColumn:tableColumn atIndex:index];
}

- (void)didChangeFilterPredicate {
  [self.filteringArray setFilterPredicate:self.filterPredicate];
  [self.tableView reloadData];
  NSNotification *notification = [NSNotification notificationWithName:NSTableViewSelectionDidChangeNotification object:self.tableView userInfo:@{}];
  [self.tableView.delegate tableViewSelectionDidChange:notification];
}

- (BOOL)canPerformAdd {
  return YES;
}

- (BOOL)canPerformDelete {
  // Delete only possible if there is a selection
  return (self.tableView.selectedRow != -1);
}

#pragma mark - Autosave
- (void)updateAutosaveInformation:(CDEAutosaveInformation *)autosaveInformation {
  // do nothing by default
}

#pragma mark - Modifying the Fetched Objects
- (void)addObject:(NSManagedObject *)object {
  [self.filteringArray addObject:object];
}

@end
