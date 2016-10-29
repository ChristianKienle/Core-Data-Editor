#import "CDEManagedObjectsPickerDataCoordinator.h"
#import "CDEManagedObjectsRequest.h"
#import "CDEManagedObjectsViewController.h"
#import "CDERequestDataCoordinator_Subclass.h"

// Additions: Begin
#import "NSTableCellView+JKNibLoading.h"
#import "NSTableView+CDEAdditions.h"
// Additions: End

@interface NSTableColumn (CDEManagedObjectsPickerDataCoordinator)

#pragma mark - Globals
+ (NSString *)identifierOfIsSelectedTableColumn_cde;

#pragma mark - Properties
@property (nonatomic, readonly, getter = isSelectedTableColumn_cde) BOOL isSelectedTableColumn_cde;
@end

@implementation NSTableColumn (CDEManagedObjectsPickerDataCoordinator)

#pragma mark - Globals
+ (NSString *)identifierOfIsSelectedTableColumn_cde {
    return @"CDE_IS_SELECTED";
}

#pragma mark - Properties
- (BOOL)isSelectedTableColumn_cde {
    return [self.identifier isEqualToString:[[self class] identifierOfIsSelectedTableColumn_cde]];
}

@end

@interface CDEManagedObjectsPickerDataCoordinator ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) id selectedManagedObjects;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end

@implementation CDEManagedObjectsPickerDataCoordinator {
    id _selectedManagedObjects;
}

#pragma mark - Properties
- (id)selectedManagedObjects {
    return [_selectedManagedObjects copy];
}

- (void)setSelectedManagedObjects:(id)selectedManagedObjects {
    _selectedManagedObjects = [selectedManagedObjects mutableCopy];
}

#pragma mark - Creating
- (id)initWithManagedObjectsRequest:(CDEManagedObjectsRequest *)request
                          tableView:(NSTableView *)tableView
       managedObjectsViewController:(CDEManagedObjectsViewController *)managedObjectsViewController
             selectedManagedObjects:(id)selectedManagedObjects
            allowsMultipleSelection:(BOOL)allowsMultipleSelection {
    NSParameterAssert((allowsMultipleSelection == NO && [selectedManagedObjects count] <= 1) || allowsMultipleSelection);
    self = [super initWithManagedObjectsRequest:request
                                      tableView:tableView
                                    searchField:managedObjectsViewController.searchField
                   managedObjectsViewController:managedObjectsViewController];
    if(self) {
        self.allowsMultipleSelection = allowsMultipleSelection;
        
        NSMutableArray *columns = [NSMutableArray arrayWithArray:self.tableColumns];
        // reset the sort descriptor prototypes
        for(NSTableColumn *column in columns) {
            column.sortDescriptorPrototype = nil;
        }
        
        // add "IS SELECTED" column
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:[NSTableColumn identifierOfIsSelectedTableColumn_cde]];
        [[column headerCell] setTitle:@"✓"];
        [[column headerCell] setAlignment:NSTextAlignmentCenter];
        [column setMinWidth:20.0];
        [column setMaxWidth:20.0];
        [column sizeToFit];
//        [column setSortDescriptorPrototype:[NSSortDescriptor sortDescriptorWithKey:self.name ascending:NO selector:selector]];

        NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO comparator:^NSComparisonResult(NSManagedObject *obj1, NSManagedObject *obj2) {
            // Easy case: obj1 or obj2 are selected
            BOOL obj1IsSelected = [_selectedManagedObjects containsObject:obj1];
            BOOL obj2IsSelected = [_selectedManagedObjects containsObject:obj2];
            
            if(obj1IsSelected && obj2IsSelected == NO) {
                return NSOrderedDescending;
            }
            
            if(obj1IsSelected == NO && obj2IsSelected) {
                return NSOrderedAscending;
            }
            
            // both are selected - compare their objectID
            return [obj1.objectID.URIRepresentation.absoluteString compare:obj2.objectID.URIRepresentation.absoluteString];
        }];
        [column setSortDescriptorPrototype:s];
        
        [columns insertObject:column atIndex:0];
        self.tableColumns = columns;
        if(selectedManagedObjects != nil) {
            self.selectedManagedObjects = selectedManagedObjects;
        } else {
            if(request.relationshipDescription.isOrdered) {
                self.selectedManagedObjects = [NSOrderedSet new];
            } else {
                self.selectedManagedObjects = [NSSet new];
            }
        }
    }
    return self;
}

- (id)initWithManagedObjectsRequest:(CDEManagedObjectsRequest *)request
                          tableView:(NSTableView *)tableView
       managedObjectsViewController:(CDEManagedObjectsViewController *)managedObjectsViewController {
    return [self initWithManagedObjectsRequest:request
                                     tableView:tableView
                  managedObjectsViewController:managedObjectsViewController
                        selectedManagedObjects:[NSSet new]
                       allowsMultipleSelection:YES];
}

- (NSView *)viewForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSInteger)index {
    if(tableColumn.isSelectedTableColumn_cde == NO) {
        return [super viewForTableColumn:tableColumn atIndex:index];
    }
    NSTableCellView *cell = [self.tableView makeViewWithIdentifier:[NSTableColumn identifierOfIsSelectedTableColumn_cde] owner:self];
    if(cell == nil) {
        //NSImageNameMenuOnStateTemplate
        cell = [NSTableCellView newTableCellViewWithNibNamed:@"CDEIsSelectedTableCellView" owner:self];
        cell.identifier = [NSTableColumn identifierOfIsSelectedTableColumn_cde] ;
    }
    return cell;
}

- (id)objectValueForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSUInteger)index {
    if(tableColumn.isSelectedTableColumn_cde == NO) {
        return [super objectValueForTableColumn:tableColumn atIndex:index];
    }
    NSManagedObject *object = [self managedObjectAtIndex:index];
    return [_selectedManagedObjects containsObject:object] ? @YES : @NO;
}

- (void)prepare {
    [super prepare];
    self.tableView.sortDescriptors = @[[self.tableColumns[0] sortDescriptorPrototype]];
}

#pragma mark - Actions
- (IBAction)takeIsSelectedValueFromSender:(id)sender {
    NSInteger row = [self.tableView rowForView_cde:sender];
    NSInteger column = [self.tableView columnForView_cde:sender];
    NSAssert(row != -1 && column != -1, @"Row or column invalid.");

    NSInteger state = [sender state];
    NSManagedObject *object = [self managedObjectAtIndex:row];
    if(state == NSOnState) {
        if(self.allowsMultipleSelection == NO) {
            [_selectedManagedObjects removeAllObjects];
        }
        [_selectedManagedObjects addObject:object];
        NSRange rowRange = [self.tableView rowsInRect:[self.tableView visibleRect]];
        NSIndexSet *rows = [NSIndexSet indexSetWithIndexesInRange:rowRange];
        NSInteger columnIndex = [self.tableView columnWithIdentifier:[NSTableColumn identifierOfIsSelectedTableColumn_cde]];
        [self.tableView reloadDataForRowIndexes:rows columnIndexes:[NSIndexSet indexSetWithIndex:columnIndex]];

    } else {
        [_selectedManagedObjects removeObject:object];
    }
}

@end
