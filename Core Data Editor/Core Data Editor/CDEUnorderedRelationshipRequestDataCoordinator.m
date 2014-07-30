#import "CDEUnorderedRelationshipRequestDataCoordinator.h"
#import "CDEManagedObjectsRequest.h"

@interface CDEUnorderedRelationshipRequestDataCoordinator ()

#pragma mark - Properties
@property (nonatomic, strong) NSArrayController *arrayController;

@end

@implementation CDEUnorderedRelationshipRequestDataCoordinator

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

- (void)prepare {
    self.arrayController = [[NSArrayController alloc] initWithContent:nil];
    NSEntityDescription *entity = self.request.relationshipDescription.destinationEntity;

    self.arrayController.entityName = entity.name;
    self.arrayController.managedObjectContext = self.request.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity.name];
    fetchRequest.entity = entity;
    
    // Person -- pets -->> Pet
    // Person <-- owner -- Pet
    // $person (pets)
    // 
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", self.request.relationshipDescription.inverseRelationship.name, self.request.managedObject];
    if(self.request.relationshipDescription.isManyToMany_cde) {
        predicate = [NSPredicate predicateWithFormat:@"ANY %K == %@", self.request.relationshipDescription.inverseRelationship.name, self.request.managedObject];
    }
    self.arrayController.filterPredicate = predicate;
    
    NSError *error = nil;
    BOOL fetched = [self.arrayController fetchWithRequest:fetchRequest merge:NO error:&error];
    if(fetched == NO) {
        NSLog(@"Error: %@", error);
        return;
    }
    
    [self.tableView bind:NSContentBinding toObject:self.arrayController withKeyPath:@"arrangedObjects" options:nil];
    [self.tableView bind:NSSortDescriptorsBinding toObject:self.arrayController withKeyPath:@"sortDescriptors" options:nil];
}

- (void)invalidate {
    [self.tableView unbind:NSContentBinding];
    [self.tableView unbind:NSSortDescriptorsBinding];
    self.arrayController = nil;
}

- (NSManagedObject *)createAndAddManagedObject {
    NSEntityDescription *entity = self.request.entityDescription;
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.request.managedObjectContext];
    NSRelationshipDescription *inverse = self.request.relationshipDescription.inverseRelationship;
    if(inverse.isToOne_cde) {
        [object setValue:self.request.managedObject forKey:inverse.name];
    } else {
        // Many-to-Many
        id relatedObjects = self.request.relatedObjects;
        [relatedObjects addObject:object];
//        [object setValue:relatedObjects forKey:inverse.name];
    }
    return object;
}

- (void)removeManagedObjectAtIndex:(NSUInteger)index {
    [self.arrayController removeObjectAtArrangedObjectIndex:index];
}

- (BOOL)canPerformAdd {
    return YES;
}

- (BOOL)canPerformDelete {
    // Delete only possible if there is a selection
    return [[self.arrayController selectedObjects] count] > 0;
}

- (void)didChangeFilterPredicate {
    self.arrayController.filterPredicate = self.filterPredicate;
    [self.tableView reloadData];
}

@end
