#import "CDERelationshipsViewController.h"
#import "CDERelationshipsViewControllerDelegate.h"
#import "CDERelationshipTableCellView.h"
#import "CDERelationshipsViewControllerItem.h"

@interface CDERelationshipsViewController () <NSTableViewDataSource, NSTableViewDelegate>

#pragma mark - Properties
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@end

@implementation CDERelationshipsViewController {
    NSMutableArray *_items;
}

#pragma mark - Creating
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.items = @[];
    }
    
    return self;
}

- (id)init {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)loadView {
    [super loadView];
    self.tableView.floatsGroupRows = NO;
}

#pragma mark - Properties
- (void)setItems:(NSArray *)items {
    _items = [items mutableCopy];
}

- (NSArray *)items {
    return [_items copy];
}

- (void)setManagedObject:(NSManagedObject *)managedObject {
    _managedObject = managedObject;
    [_items removeAllObjects];
    for(NSRelationshipDescription *relationship in [managedObject.entity sortedRelationships_cde]) {
        CDERelationshipsViewControllerItem *item = [[CDERelationshipsViewControllerItem alloc] initWithRelationship:relationship managedObject:self.managedObject];
        [_items addObject:item];
    }
    [self.tableView reloadData];
    if(_items.count > 0) {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
    }
}

#pragma mark - Updating the UI
- (void)updateUI {
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        if(row == 0) {
            return;
        }
        
        if(rowView.numberOfColumns == 0) {
            return;
        }
        
        CDERelationshipTableCellView *cellView = [rowView viewAtColumn:0];
        [cellView updateTitle];
        [cellView reloadBadgeValue];
    }];
}

#pragma mark - NSTableViewDataSource / NSTableViewDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.items.count + 1;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if(row == 0) {
        NSTextField *headerTextField = [self.tableView makeViewWithIdentifier:@"HeaderCell" owner:self];
        headerTextField.stringValue = @"RELATIONSHIPS";
        return headerTextField;
    }
    CDERelationshipTableCellView *cell = [self.tableView makeViewWithIdentifier:@"RelationshipCell" owner:self];
    if(cell == nil) {
        // Help
    }
//    [cell setBadgeValue:arc4random_uniform(50)];
    return cell;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if(row == 0) {
        return @"RELATIONSHIPS";
    }
    return _items[row-1];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if(self.delegate == nil) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(relationshipsViewController:didSelectRelationshipDescription:)] == NO) {
        return;
    }
    NSInteger row = [self.tableView selectedRow];
    NSRelationshipDescription *selectedRelationship = nil;
    if(row != -1 && row != 0) {
        selectedRelationship = [_items[row-1] relationshipDescription];
    }
    [self.delegate relationshipsViewController:self didSelectRelationshipDescription:selectedRelationship];
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return row == 0;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    return rowIndex != 0;
}

#pragma mark - NSResponder
- (BOOL)performKeyEquivalent:(NSEvent *)event {
    // '1' => code: 18 0
    // '2' => code: 19 1
    // '3' => code: 20 2
    // '4' => code: 21 3
    // '5' => code: 23 4
    // '6' => code: 22 5
    // '7' => code: 26 6
    // '8' => code: 28 7
    // '9' => code: 25 8
    // '0' => code: 29 9
    NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
    if( flags == NSCommandKeyMask ){
        unsigned short keyCode = [event keyCode];
        
        NSDictionary *itemIndexesByKeyCode = @{ @18 : @0,
                                                @19 : @1,
                                                @20 : @2,
                                                @21 : @3,
                                                @23 : @4,
                                                @22 : @5,
                                                @26 : @6,
                                                @28 : @7,
                                                @25 : @8,
                                                @29 : @9
                                                };
        
        id keyCodeValue = @(keyCode);
        NSNumber *itemIndex = itemIndexesByKeyCode[keyCodeValue];
        if(itemIndex == nil) {
            return NO;
        }

        NSUInteger itemIndexValue = itemIndex.unsignedIntegerValue;
        if(itemIndexValue >= [_items count]) {
            return NO;
        }
        
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:itemIndexValue+1] byExtendingSelection:NO];
        return YES;
    }

    return NO;
}


@end
