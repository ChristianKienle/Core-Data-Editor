#import "CDEToOneRelationshipRequestDataCoordinator.h"
#import "CDEManagedObjectsRequest.h"
#import "CDEAutosaveInformation.h"
#import "CDEEntityAutosaveInformation.h"
#import "CDEEntityAutosaveInformationItem.h"
#import "CDERequestDataCoordinator_Subclass.h"

#import "CDEManagedObjectsViewController.h"

@implementation CDEToOneRelationshipRequestDataCoordinator

#pragma mark - Implementing CDERequestDataCoordinator
- (NSInteger)numberOfObjects {
  if(self.request.relatedObject == nil) {
    return 0;
  }
  return 1;
}

- (id)objectValueForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSUInteger)index {
  NSManagedObject *object = self.request.relatedObject;
  id objectValue = [object valueForKey:tableColumn.identifier];
  return objectValue;
}

- (NSManagedObject *)managedObjectAtIndex:(NSUInteger)index {
  NSParameterAssert(index == 0);
  NSParameterAssert(self.request.relatedObject != nil);
  NSManagedObject *object = self.request.relatedObject;
  return object;
}

- (NSUInteger)indexOfManagedObject:(NSManagedObject *)managedObject {
  NSParameterAssert(managedObject);
  return 0;
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
}

- (void)invalidate {
  
}

- (NSManagedObject *)createAndAddManagedObject {
  NSAssert(self.request.relatedObject == nil, @"");
  NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:self.request.entityDescription.name inManagedObjectContext:self.request.managedObjectContext];
  [self.request.managedObject setValue:object forKey:self.request.relationshipDescription.name];
  return object;
}

- (void)removeManagedObjectAtIndex:(NSUInteger)index {
  [self.request.managedObjectContext deleteObject:self.request.relatedObject];
}

- (NSView *)viewForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSInteger)index {
  return [super viewForTableColumn:tableColumn atIndex:index];
}

- (BOOL)canPerformAdd {
  return self.request.relatedObject == nil;
}

- (BOOL)canPerformDelete {
  return self.request.relatedObject != nil;
}

- (void)updateAutosaveInformation:(CDEAutosaveInformation *)autosaveInformation {
  // do nothing by default
}


#pragma mark - Helper
- (NSDictionary *)tableColumnsByIdentifier {
  NSMutableDictionary *result = [NSMutableDictionary new];
  for(NSTableColumn *column in self.tableColumns) {
    result[column.identifier] = column;
  }
  return result;
}



@end
