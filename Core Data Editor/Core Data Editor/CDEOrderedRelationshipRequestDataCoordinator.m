#import "CDEOrderedRelationshipRequestDataCoordinator.h"
#import "CDEManagedObjectsRequest.h"
#import "NSSortDescriptor+CDEAdditions.h"
#import "CDERequestDataCoordinator_Subclass.h"
#import "CDEOrderIndexTableCellView.h"
#import "NSTableCellView+JKNibLoading.h"

@interface NSTableColumn (OrderedRelationshipRequestDataCoordinator)

- (BOOL)isOrderIndexColumn_cde;

@end

@implementation NSTableColumn (OrderedRelationshipRequestDataCoordinator)

- (BOOL)isOrderIndexColumn_cde {
    return [self.identifier isEqualToString:@"CDE_orderIndexColumn"];
}

@end

@interface CDEOrderedRelationshipRequestDataCoordinator ()

#pragma mark - Properties
@property (nonatomic, copy) NSOrderedSet *filteredRelatedObjects;

@end

@implementation CDEOrderedRelationshipRequestDataCoordinator

#pragma mark - Properties
- (NSOrderedSet *)resultingRelatedObjects {
    if(self.filterPredicate == nil) {
        return self.request.relatedObjects;
    }
    // We are filtering...
    if(self.filteredRelatedObjects == nil) {
        [self recreateFilteredRelatedObjects];
    }
    return self.filteredRelatedObjects;
}

- (void)recreateFilteredRelatedObjects {
    self.filteredRelatedObjects = nil;
    
    if(self.filterPredicate == nil) {
        return;
    }

    NSArray *relatedObjectsAsArray = [self.request.relatedObjects array];
    NSArray *filteredRelatedObjectsAsArray = [relatedObjectsAsArray filteredArrayUsingPredicate:self.filterPredicate];
    self.filteredRelatedObjects = [NSOrderedSet orderedSetWithArray:filteredRelatedObjectsAsArray];
}

#pragma mark - CDERequestDataCoordinator
- (id)initWithManagedObjectsRequest:(CDEManagedObjectsRequest *)request tableView:(NSTableView *)tableView searchField:(NSSearchField *)searchField managedObjectsViewController:(CDEManagedObjectsViewController *)managedObjectsViewController {
    NSParameterAssert(request.relationshipDescription.isOrdered);
    
    self = [super initWithManagedObjectsRequest:request tableView:tableView searchField:searchField managedObjectsViewController:managedObjectsViewController];
    if(self) {
        // Add one more column (the order column)
        NSTableColumn *orderIndexColumn = [[NSTableColumn alloc] initWithIdentifier:@"CDE_orderIndexColumn"];
        [[orderIndexColumn headerCell] setTitle:@"#"];
        [[orderIndexColumn headerCell] setAlignment:NSCenterTextAlignment];
        [orderIndexColumn setMinWidth:50.0];
        [orderIndexColumn setWidth:50.0];
        
        NSMutableArray *columns = [self.tableColumns mutableCopy];
        [columns insertObject:orderIndexColumn atIndex:0];
        
        self.tableColumns = columns;
    }
    return self;
}

- (NSInteger)numberOfObjects {
    NSOrderedSet *relatedObjects = [self resultingRelatedObjects];
    if(relatedObjects == nil) {
        return 0;
    }
    return [relatedObjects count];
}

// Returning nil is okay
- (id)objectValueForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSUInteger)index {
    if([tableColumn isOrderIndexColumn_cde]) {
        return @(index + 1);
    }
    NSOrderedSet *relatedObjects = [self resultingRelatedObjects];

    NSManagedObject *object = relatedObjects[index];
    id objectValue = [object valueForKey:tableColumn.identifier];
    return objectValue;
}

- (NSManagedObject *)managedObjectAtIndex:(NSUInteger)index {
    NSOrderedSet *relatedObjects = [self resultingRelatedObjects];
    if(relatedObjects == nil) {
        return nil;
    }

    if([relatedObjects count] <= index) {
        return nil;
    }
    
    NSManagedObject *object = relatedObjects[index];
    return object;
}

- (NSUInteger)indexOfManagedObject:(NSManagedObject *)managedObject {
    NSParameterAssert(managedObject);
    NSOrderedSet *relatedObjects = [self resultingRelatedObjects];
    NSUInteger index = [relatedObjects indexOfObject:managedObject];
    return index;
}

- (void)prepare {
}

- (void)invalidate {
}

- (NSManagedObject *)createAndAddManagedObject {
    NSEntityDescription *entity = self.request.entityDescription;
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.request.managedObjectContext];
    NSRelationshipDescription *inverse = self.request.relationshipDescription.inverseRelationship;
    if(inverse.isToOne_cde) {
        [object setValue:self.request.managedObject forKey:inverse.name];
    } else {
        // Many-to-Many
        id relatedObjects = [self.request.relatedObjects mutableCopy];
        [relatedObjects addObject:object];
        [object setValue:relatedObjects forKey:inverse.name];
    }
    [self.tableView reloadData];
    return object;
}

- (void)removeManagedObjectAtIndex:(NSUInteger)index {
    // FIXME: Nothing to implement here?
}

- (NSView *)viewForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSInteger)index {
    //
    if([tableColumn isOrderIndexColumn_cde]) {
        //
        NSString *identifier = tableColumn.identifier;
        NSTableCellView *cell = [self.tableView makeViewWithIdentifier:identifier owner:self];
        
            if(cell == nil) {
                cell = [CDEOrderIndexTableCellView newTableCellViewWithNibNamed:@"CDEOrderIndexTableCellView" owner:self];
                cell.identifier = identifier;
            }

        return cell;
    }

    return [super viewForTableColumn:tableColumn atIndex:index];
}

- (void)didChangeFilterPredicate {
    [self recreateFilteredRelatedObjects];
    [self.tableView reloadData];
}

- (BOOL)canPerformAdd {
    return YES;
}

- (BOOL)canPerformDelete {
    // Delete only possible if there is a selection
    NSOrderedSet *relatedObjects = [self resultingRelatedObjects];
    if(relatedObjects == nil) {
        return NO;
    }
    return ([relatedObjects count] > 0);
}


@end
