#import "CDERequestDataCoordinator.h"
#import "CDERequestDataCoordinator_Subclass.h"
#import "CDEManagedObjectsRequest.h"
#import "CDEManagedObjectsViewController.h"
#import "CDEDatePickerWindow.h"
#import "CDEDatePickerWindowDelegate.h"
#import "CDEEntityAutosaveInformation.h"
#import "CDEEntityAutosaveInformationItem.h"

// Cells: Begin
#import "CDEFloatingPointValueTableCellView.h"
#import "CDEToManyRelationshipTableCellView.h"
#import "CDEToOneRelationshipTableCellView.h"
// Cells: End

// Additions: Begin
#import "NSTableView+CDEAdditions.h"
#import "NSSortDescriptor+CDEAdditions.h"
#import "NSTableCellView+JKNibLoading.h"
// Additions: End

#import "NSTableColumn+CDERequestDataCoordinator.h"
#import "CDETextEditorController.h"

@interface CDERequestDataCoordinator () <NSTextFieldDelegate, CDEDatePickerWindowDelegate>

#pragma mark - Properties
@property (nonatomic, strong, readwrite) CDEManagedObjectsRequest *request;
@property (nonatomic, weak, readwrite) NSTableView *tableView;
@property (nonatomic, weak, readwrite) NSSearchField *searchField;
@property (nonatomic, weak, readwrite) CDEManagedObjectsViewController *managedObjectsViewController;
@property (nonatomic, copy) NSString *filterByKeyPath;
@property (nonatomic, strong) NSAttributeDescription *filterByAttributeDescription;
@property (nonatomic, copy, readwrite) NSPredicate *filterPredicate;
@property (nonatomic, strong) CDEDatePickerWindow *datePicker;
@property (nonatomic, strong) CDETextEditorController *textEditorController;

@end

@implementation CDERequestDataCoordinator

#pragma mark - Private Configuration
+ (BOOL)createdRelationshipColumns {
    return NO;
}

#pragma mark - Creating
- (id)initWithManagedObjectsRequest:(CDEManagedObjectsRequest *)request
                          tableView:(NSTableView *)tableView
                        searchField:(NSSearchField *)searchField
       managedObjectsViewController:(CDEManagedObjectsViewController *)managedObjectsViewController {
  NSParameterAssert(request);
  NSParameterAssert(tableView);
  NSParameterAssert(searchField);
  NSParameterAssert(managedObjectsViewController);
    self = [super init];
    if(self) {
        self.request = request;
        self.tableView = tableView;
        self.searchField = searchField;
        self.managedObjectsViewController = managedObjectsViewController;

        // Add Columns
        // Add objectID Column
        NSMutableArray *columns = [NSMutableArray new];

        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"objectID"];
        [[column headerCell] setTitle:[@"objectID" humanReadableStringAccordingToUserDefaults_cde]];
        [column sizeToFit];
        [column setMinWidth:100.0];
        [column setSortDescriptorPrototype:[NSSortDescriptor newSortDescriptorForObjectIDColumn_cde]];

        [columns addObject:column];

        // To-One Relationships
        if([[self class] createdRelationshipColumns]) {
        for(NSRelationshipDescription *relationshipDescription in [self.request.entityDescription sortedToOneRelationships_cde]) {
            NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:relationshipDescription.name];
            [[column headerCell] setTitle:relationshipDescription.nameForDisplay_cde];
            [column sizeToFit];
            [column setMinWidth:100.0];
            [columns addObject:column];
        }
            // Add Relationship Columns
            for(NSRelationshipDescription *relationshipDescription in [[self.request.entityDescription relationshipsByName] allValues]) {
                if(relationshipDescription.isToMany == NO) {
                    continue;
                }
                NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:relationshipDescription.name];
                [[column headerCell] setTitle:relationshipDescription.nameForDisplay_cde];
                [column sizeToFit];
                [column setMinWidth:100.0];
                [columns addObject:column];
            }
        }

        // Add Attribute Columns
        for(NSAttributeDescription *attributeDescription in [self.request.entityDescription supportedAttributes_cde]) {
            NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:attributeDescription.name];
            [[column headerCell] setTitle:attributeDescription.nameForDisplay_cde];
            [column sizeToFit];
            [column setMinWidth:100.0];
            [column setSortDescriptorPrototype:attributeDescription.sortDescriptorPrototype_cde];
            [columns addObject:column];
        }

        self.tableColumns = columns;
        self.filterByKeyPath = @"";

        // Create Search Field Menu
        NSMenu *cellMenu = [[NSMenu alloc] initWithTitle:@"Search Menu"];
        NSArray *attributes = [[request.entityDescription attributesByName] allValues];
        NSUInteger attributeIndex = 1;
        for(NSAttributeDescription *attribute in attributes) {
            if([attribute attributeType] == NSStringAttributeType || attribute.isAttributeWithIntegerCharacteristics_cde) {
                NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:[attribute nameForDisplay_cde] action:@selector(setSearchCategoryFrom:) keyEquivalent:@""];
                [newItem setTarget:self];
                [newItem setTag:attributeIndex];
                [newItem setRepresentedObject:attribute];
                [cellMenu insertItem:newItem atIndex:attributeIndex - 1];
                attributeIndex++;
            }
        }
        [[searchField cell] setSearchMenuTemplate:cellMenu];
        if([cellMenu numberOfItems] > 0) {
            [self setSearchCategoryFrom:[cellMenu itemAtIndex:0]];
        }
        [[self searchField] setEnabled:([cellMenu numberOfItems] > 0) ? YES : NO];
        self.searchField.delegate = self;
        [[self.searchField cell] setPlaceholderString:@""];
    }
    return self;
}

- (id)init {
    return [self initWithManagedObjectsRequest:nil tableView:nil searchField:nil managedObjectsViewController:nil];
}

#pragma mark - For Subclassers
- (NSInteger)numberOfObjects {
    @throw [NSException exceptionWithName:@"CDEAbstractNotImplemented" reason:nil userInfo:nil];
}

// Returning nil is okay
- (id)objectValueForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSUInteger)index {
    @throw [NSException exceptionWithName:@"CDEAbstractNotImplemented" reason:nil userInfo:nil];
}

- (id)objectValueByTransformingObjectValue:(id)objectValue forTableColumn:(NSTableColumn *)tableColumn atIndex:(NSInteger)index {
    NSPropertyDescription *property = [self propertyDescriptionForTableColumn:tableColumn];

    if(objectValue == nil) {
        // returning nil here would cause the objectValue to become an instance of NSManagedObject which we do not want.
        // Instead we determine the attribute type and compute a default value
        if(property.isAttributeDescription_cde) {
            NSAttributeDescription *attribute = [self attributeDescriptionForTableColumn:tableColumn];
            NSAttributeType type = attribute.attributeType;
            if(type == NSBooleanAttributeType) {
                objectValue = @(NSMixedState);
            }
            if(type == NSStringAttributeType) {
                objectValue = [NSNull null];
            }
            if(attribute.isAttributeWithFloatingPointCharacteristics_cde) {
                objectValue = [NSNull null];
            }
            if(type == NSBinaryDataAttributeType || type == NSTransformableAttributeType) {
                objectValue = [NSNull null];
            }
            if(type == NSDateAttributeType) {
                objectValue = [NSNull null];
            }
            if(attribute.isAttributeWithIntegerCharacteristics_cde) {
                objectValue = [NSNull null];
            }
        }
    }

    if(property.isRelationshipDescription_cde && property != nil) {
        NSRelationshipDescription *relation = (NSRelationshipDescription *)property;
        NSManagedObject *object = [self managedObjectAtIndex:index];
        objectValue = [[CDEManagedObjectsRequest alloc] initWithManagedObject:object relationshipDescription:relation];
    }

    return objectValue;
}

- (NSManagedObject *)managedObjectAtIndex:(NSUInteger)index {
    @throw [NSException exceptionWithName:@"CDEAbstractNotImplemented" reason:nil userInfo:nil];
}

- (NSUInteger)indexOfManagedObject:(NSManagedObject *)managedObject {
    @throw [NSException exceptionWithName:@"CDEAbstractNotImplemented" reason:nil userInfo:nil];
}

- (void)prepare {
    @throw [NSException exceptionWithName:@"CDEAbstractNotImplemented" reason:nil userInfo:nil];
}

- (void)invalidate {
    @throw [NSException exceptionWithName:@"CDEAbstractNotImplemented" reason:nil userInfo:nil];
}

- (NSManagedObject *)createAndAddManagedObject {
    @throw [NSException exceptionWithName:@"CDEAbstractNotImplemented" reason:nil userInfo:nil];
}

- (void)removeManagedObjectAtIndex:(NSUInteger)index {
    @throw [NSException exceptionWithName:@"CDEAbstractNotImplemented" reason:nil userInfo:nil];
}

- (NSIndexSet *)indexesOfSelectedManagedObjects {
    return [self.tableView selectedRowIndexes];
}

- (NSArray *)selectedManagedObjects {
    NSIndexSet *indexes = [self indexesOfSelectedManagedObjects];
    NSMutableArray *result = [NSMutableArray new];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        NSManagedObject *object = [self managedObjectAtIndex:index];
        [result addObject:object];
    }];
    return result;
}

- (void)removeSelectedManagedObjects {
    NSIndexSet *indexes = [self indexesOfSelectedManagedObjects];
    NSMutableOrderedSet *objects = [NSMutableOrderedSet new];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        NSManagedObject *object = [self managedObjectAtIndex:index];
        NSAssert(object, @"object cannot be nil.");
        [objects addObject:object];
    }];
    for(NSManagedObject *object in objects) {
        [self.request.managedObjectContext deleteObject:object];
    }
    [self.tableView reloadData];
}

- (NSView *)viewForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSInteger)atIndex {
    NSPropertyDescription *property = [self propertyDescriptionForTableColumn:tableColumn];
    NSString *identifier = tableColumn.identifier;
    NSTableCellView *cell = [self.tableView makeViewWithIdentifier:identifier owner:self.managedObjectsViewController];

    if(property.isAttributeDescription_cde || [identifier isEqualToString:@"objectID"]) {
        NSAttributeType type = [self attributeTypeForTableColumn:tableColumn];

        if(cell == nil) {
            Class cellClass = [NSAttributeDescription tableCellViewClassForAttributeType_cde:type];
            NSString *nibName = NSStringFromClass(cellClass);
            cell = [cellClass newTableCellViewWithNibNamed:nibName owner:self.managedObjectsViewController];
            cell.identifier = identifier;
        }

        BOOL isFloatingPointAttribute = (type == NSDoubleAttributeType || type == NSFloatAttributeType || type == NSDecimalAttributeType);

        if(isFloatingPointAttribute) {
            [(CDEFloatingPointValueTableCellView *)cell updateFormatter];
        }
        if(type == NSDateAttributeType) {
            [(CDEFloatingPointValueTableCellView *)cell updateFormatter];
        }

        [cell setNeedsLayout:YES];
        return cell;
    }
    if(property.isRelationshipDescription_cde) {
        if(cell == nil) {
            NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
            Class cellClass = Nil;
            if(relationship.isToMany) {
                cellClass = [CDEToManyRelationshipTableCellView class];
            } else {
                cellClass = [CDEToOneRelationshipTableCellView class];
            }
            cell = [cellClass newTableCellViewWithNibNamed:NSStringFromClass(cellClass) owner:self.managedObjectsViewController];
        }
        cell.identifier = identifier;
        [cell setNeedsLayout:YES];
        return cell;
    }
    return nil;
}

#pragma mark - Helper
- (NSAttributeType)attributeTypeForTableColumn:(NSTableColumn *)tableColumn {
    NSParameterAssert(tableColumn);

    // Special Case: objectID-Column
    NSString *attributeName = tableColumn.identifier;
    if([attributeName isEqualToString:@"objectID"]) {
        return NSObjectIDAttributeType;
    }

    // Regular Case
    NSAttributeDescription *attribute = [self attributeDescriptionForTableColumn:tableColumn];
    return attribute.attributeType;
}

- (NSAttributeDescription *)attributeDescriptionForTableColumn:(NSTableColumn *)tableColumn {
    NSParameterAssert(tableColumn);
    NSString *attributeName = tableColumn.identifier;
    NSParameterAssert(attributeName);
    return [self.request.entityDescription attributesByName][attributeName];
}

- (NSPropertyDescription *)propertyDescriptionForTableColumn:(NSTableColumn *)tableColumn {
    NSParameterAssert(tableColumn);
    NSString *propertyName = tableColumn.identifier;
    NSParameterAssert(propertyName);
    return [self.request.entityDescription propertiesByName][propertyName];
}

- (IBAction)takeBoolValueFromSender:(id)sender {
    NSInteger row = [self.tableView rowForView_cde:sender];
    NSInteger column = [self.tableView columnForView_cde:sender];
    NSAssert(row != -1 && column != -1, @"Row or column invalid.");

    NSCellStateValue state = [sender state];
    id value = nil;
    switch (state) {
        case NSOnState:
            value = @YES;
            break;
        case NSOffState:
            value = @NO;
            break;
        case NSMixedState:
            value = nil;
            break;
        default:
            break;
    }
    NSManagedObject *object = [self managedObjectAtIndex:row];
    NSTableColumn *tableColumn = [self.tableView tableColumns][column];

    [object setValue:value forKey:tableColumn.identifier];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    if([notification.object isEqual:self.searchField]) {
        return;
    }

    NSTextField *textField = [notification object];

    NSInteger row = [self.tableView rowForView_cde:textField];
    NSInteger column = [self.tableView columnForView_cde:textField];
    NSAssert(row != -1 && column != -1, @"Row or column invalid.");

    NSManagedObject *object = [self managedObjectAtIndex:row];
    NSTableColumn *tableColumn = [self.tableView tableColumns][column];

    [object setValue:[[notification object] objectValue] forKey:tableColumn.identifier];
}

- (void)binaryValueTextField:(NSTextField *)textField didChangeBinaryValue:(NSData *)binaryValue {
    NSInteger row = [self.tableView rowForView_cde:textField];
    NSInteger column = [self.tableView columnForView_cde:textField];
    NSAssert(row != -1 && column != -1, @"Row or column invalid.");

    NSManagedObject *object = [self managedObjectAtIndex:row];
    NSTableColumn *tableColumn = [self.tableView tableColumns][column];

    [object setValue:binaryValue forKey:tableColumn.identifier];
}

- (IBAction)relationshipBadgeButtonClicked:(id)sender {
}

#pragma mark - Special Shit
- (IBAction)showDatePickerForSender:(id)sender {
    // Determine the value to display
    NSInteger row = [self.tableView rowForView_cde:sender];
    NSInteger column = [self.tableView columnForView_cde:sender];
    NSAssert(row != -1 && column != -1, @"Row or column invalid.");

    NSManagedObject *object = [self managedObjectAtIndex:row];

    NSLog(@"show date picker for r: %li - c: %li", row, column);

    NSTableColumn *tableColumn = [self.tableView tableColumns][column];
    NSPropertyDescription *property = [self propertyDescriptionForTableColumn:tableColumn];

    NSDate *dateValue = [object valueForKey:property.name];

    if(self.datePicker == nil) {
        self.datePicker = [CDEDatePickerWindow new];
    }
    self.datePicker.delegate = self;

    NSDictionary *representedObject = @{ @"managedObject" : object,
                                         @"attributeName" : property.name };

    self.datePicker.representedObject = representedObject;

    [self.datePicker showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge andDisplayDate:dateValue];
}

- (IBAction)showTextEditorForSender:(id)sender {
    NSInteger row = [self.tableView rowForView_cde:sender];
    NSInteger column = [self.tableView columnForView_cde:sender];
    NSAssert(row != -1 && column != -1, @"Row or column invalid.");

    NSManagedObject *object = [self managedObjectAtIndex:row];

    NSLog(@"show date picker for r: %li - c: %li", row, column);

    NSTableColumn *tableColumn = [self.tableView tableColumns][column];
    NSPropertyDescription *property = [self propertyDescriptionForTableColumn:tableColumn];

    NSString *stringValue = [object valueForKey:property.name];

    if(self.textEditorController == nil) {
        self.textEditorController = [CDETextEditorController new];
    }

//    NSDictionary *representedObject = @{ @"managedObject" : object,
//                                         @"attributeName" : property.name };

//    self.datePicker.representedObject = representedObject;

    [self.textEditorController showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge stringValue:stringValue completionHandler:^(NSString *editedStringValue) {
        [object setValue:editedStringValue forKey:property.name];
        NSUInteger rowIndex = [self indexOfManagedObject:object];
        NSIndexSet *columIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableColumns.count)];
        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] columnIndexes:columIndexes];
    }];
//    [self.datePicker showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge andDisplayDate:dateValue];
}

#pragma mark CDEDatePickerWindowDelegate
- (void)datePickerWindow:(CDEDatePickerWindow *)datePickerWindow didConfirmDate:(NSDate *)confirmedDate {
    NSParameterAssert(datePickerWindow.representedObject != nil);
    NSParameterAssert([datePickerWindow.representedObject isKindOfClass:[NSDictionary class]]);

    // In this case the representedObject of datePickerWindow is a NSDictionary with two keys:
    // 1. managedObject (the edited managed object)
    // 2. attributeName (the name of the edited attribute)
    NSDictionary *representedObject = datePickerWindow.representedObject;
    NSManagedObject *object = representedObject[@"managedObject"];
    NSString *attributeName = representedObject[@"attributeName"];

    NSAssert(object, @"representedObject has no managedObject.");
    NSAssert(attributeName, @"representedObject has no attribute name.");

    // Set the value on it
    [object setValue:confirmedDate forKey:attributeName];

    // Reload the table
    NSUInteger rowIndex = [self indexOfManagedObject:object];
    NSIndexSet *columIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableColumns.count)];
    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] columnIndexes:columIndexes];

    self.datePicker = nil;
}

- (void)datePickerWindowDidCancel:(CDEDatePickerWindow *)datePickerWindow {
    // Do nothing
    self.datePicker = nil;
}

#pragma mark - For Subclassers / UI
- (void)updateUIOfVisibleObjects {
    for(NSTableColumn *column in self.tableView.tableColumns) {
        if(column.isObjectIDColumn_cde) {
            [[column headerCell] setTitle:[@"objectID" humanReadableStringAccordingToUserDefaults_cde]];
            continue;
        }
        // Determine if column is a property column
        NSPropertyDescription *property = [self propertyDescriptionForTableColumn:column];
        if(property == nil) {
            // unknown column
            continue;
        }
        [[column headerCell] setTitle:property.nameForDisplay_cde];
    }
    [self.tableView.headerView setNeedsDisplay:YES];

    // objectID column
    NSInteger indexOfObjectIDColumn = [self.tableView columnWithIdentifier:@"objectID"];
    if(indexOfObjectIDColumn != -1) {
        NSRange visibleRowsRange = [self.tableView rowsInRect:self.tableView.visibleRect];
        NSIndexSet *visibleRows = [NSIndexSet indexSetWithIndexesInRange:visibleRowsRange];
        [self.tableView reloadDataForRowIndexes:visibleRows columnIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)indexOfObjectIDColumn]];
    }

    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        // Handle the objectID column
        if(indexOfObjectIDColumn != -1) {
            NSTableCellView *cell = (NSTableCellView *)[rowView viewAtColumn:indexOfObjectIDColumn];
            NSManagedObjectID *objectID = cell.objectValue;
            cell.textField.stringValue = [objectID stringRepresentationForDisplay_cde];
        }
        for(NSUInteger columnIndex = 0; columnIndex < rowView.numberOfColumns; columnIndex++) {
            NSTableCellView *cell = (NSTableCellView *)[rowView viewAtColumn:columnIndex];
            if([cell respondsToSelector:@selector(updateFormatter)]) {
                [cell performSelector:@selector(updateFormatter)];
            }
        }
    }];
}

#pragma mark - For Subclassers / Searching
- (void)didChangeFilterPredicate {

}

#pragma mark - Helpers

+ (id)transformedValueFromString:(NSString *)inputString attributeType:(NSAttributeType)attributeType {
    if(attributeType == NSStringAttributeType) {
        return inputString;
    }
    if([NSAttributeDescription attributeTypeHasIntegerCharacteristics_cde:attributeType]) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        return [numberFormatter numberFromString:inputString];
    }
    return nil;
}

- (IBAction)setSearchCategoryFrom:(NSMenuItem *)menuItem {
    NSAttributeDescription *attributeDescription = menuItem.representedObject;
    [self setFilterByKeyPath:attributeDescription.name];
    [self setFilterByAttributeDescription:attributeDescription];
    [[self.searchField cell] setPlaceholderString:attributeDescription.nameForDisplay_cde];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    if(![notification.object isEqual:self.searchField]) {
        return;
    }
    if([[self.searchField stringValue] length] == 0 || [[self filterByKeyPath] length] == 0) {
        self.filterPredicate = nil;
        [self didChangeFilterPredicate];
        return;
    }

    id searchFieldValue = [[self class] transformedValueFromString:[self.searchField stringValue]
                                             attributeType:[[self filterByAttributeDescription] attributeType]];
    NSPredicateOperatorType operatorType = [NSAttributeDescription predicateOperatorTypeForAttributeType_cde:[[self filterByAttributeDescription] attributeType]];
    self.filterPredicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:[NSString stringWithFormat:@"%@", [self filterByKeyPath]]] rightExpression:[NSExpression expressionForConstantValue:searchFieldValue] modifier:NSDirectPredicateModifier type:operatorType options:NSDiacriticInsensitivePredicateOption];
    [self didChangeFilterPredicate];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item {
    [item setState:[[[item representedObject] name] isEqualToString:[self filterByKeyPath]] ? NSOnState : NSOffState];
    return YES;
}

#pragma mark - For Subclassers / Used to disable/enable the buttons
- (BOOL)canPerformAdd {
    return NO;
}

- (BOOL)canPerformDelete {
    return NO;
}

#pragma mark - Autosave
- (CDEEntityAutosaveInformation *)entityAutosaveInformation {
    NSMutableArray *items = [NSMutableArray new];
    for(NSTableColumn *column in self.tableView.tableColumns) {
        CDEEntityAutosaveInformationItem *item = [CDEEntityAutosaveInformationItem newWithIdentifier:column.identifier width:column.width];
        [items addObject:item];
    }
    CDEEntityAutosaveInformation *result = [CDEEntityAutosaveInformation newWithEntityName:self.request.entityDescription.name items:items];
    return result;
}


@end
