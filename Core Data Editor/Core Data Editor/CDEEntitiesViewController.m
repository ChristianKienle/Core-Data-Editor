#import "CDEEntitiesViewController.h"
#import "CDEEntitiesViewControllerDelegate.h"
#import "CDEEntityTableCellView.h"

@interface CDEEntitiesViewController ()

#pragma mark - Properties
@property (nonatomic, copy) NSDictionary *rootItem;
@property (weak) IBOutlet NSOutlineView *outlineView;

@end

@implementation CDEEntitiesViewController

#pragma mark - Creating
- (id)init {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleManagedObjectContextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

- (void)handleManagedObjectContextDidChange:(NSNotification *)notification {
    // Ignore everything that is not our context
    if([notification.object isEqual:self.managedObjectContext] == NO) {
        return;
    }
    
    NSMutableSet *changedObjects = [NSMutableSet new];

    NSSet *inserted = notification.userInfo[NSInsertedObjectsKey];
    [changedObjects unionSet:inserted];
    
    NSSet *deleted = notification.userInfo[NSDeletedObjectsKey];
    [changedObjects unionSet:deleted];

    if(changedObjects.count == 0) {
        return;
    }

    NSMutableSet *dirtyEntities = [NSMutableSet new];
    for(NSManagedObject *object in changedObjects) {
        [dirtyEntities addObject:object.entity];
    }
    
    [self.outlineView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        BOOL isGroupRow = rowView.isGroupRowStyle;
        if(isGroupRow) {
            return;
        }
        NSUInteger columnViewCount = rowView.numberOfColumns;
        if(columnViewCount == 0) {
            return;
        }
        
        CDEEntityTableCellView *cellView = [rowView viewAtColumn:0];
        NSEntityDescription *entity = [cellView objectValue];
        NSAssert([entity isKindOfClass:[NSEntityDescription class]], @"Invalid Class");
        BOOL updateView = [dirtyEntities containsObject:entity];
        if(updateView) {
            [self updateUIOfEntityTableCellView:cellView withEntityDescription:entity];
        }
     
    }];
}

#pragma mark - Properties
- (NSEntityDescription *)selectedEntityDescription {
    NSInteger row = self.outlineView.selectedRow;
    if(row == -1) {
        return nil;
    }
    id item = [self.outlineView itemAtRow:row];
    return item;
}

#pragma mark - Displaying Data
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSMutableArray *rootEntities = [NSMutableArray new];
    for(NSEntityDescription *entity in model) {
        if(entity.superentity != nil) {
            continue;
        }
        [rootEntities addObject:entity];
    }
    self.rootItem = @{ @"subentities" : rootEntities };
    [self.outlineView reloadData];
    [self.outlineView expandItem:self.rootItem expandChildren:NO];
    [self.outlineView setFloatsGroupRows:NO];
}

#pragma mark - UI
- (void)updateUIOfVisibleEntities {
    [self.outlineView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        BOOL isGroupRow = rowView.isGroupRowStyle;
        if(isGroupRow) {
            return;
        }
        NSUInteger columnViewCount = rowView.numberOfColumns;
        if(columnViewCount == 0) {
            return;
        }
        
        CDEEntityTableCellView *cellView = [rowView viewAtColumn:0];
        NSEntityDescription *entity = [cellView objectValue];
        NSAssert([entity isKindOfClass:[NSEntityDescription class]], @"Invalid Class");
        [self updateUIOfEntityTableCellView:cellView withEntityDescription:entity];
    }];
}

#pragma mark - Helper
- (NSArray *)_childrenForItem:(id)item {
    NSArray *children;
    if (item == nil) {
        children = @[self.rootItem];
    } else {
        if([item isKindOfClass:[NSDictionary class]]) {
            children = item[@"subentities"];
        }
        else {
            children = [item valueForKey:@"subentities"];

        }
        
    }
    return children;
}

#pragma mark - NSOutlineView
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [item isEqual:self.rootItem];
//    BOOL isRootItem = [[item representedObject] isKindOfClass:[NSDictionary class]];
//    return isRootItem;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [self _childrenForItem:item][index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([outlineView parentForItem:item] == nil) {
        return YES;
    } else {
        return [[item subentities] count] > 0;
    }
}

- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if(self.rootItem == nil) {
        return 0;
    }
    return [[self _childrenForItem:item] count];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if(self.delegate == nil) {
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(entitiesViewController:didSelectEntitiyDescription:)] == NO) {
        return;
    }
    
    id selectedEntity = nil;
    if ([self.outlineView selectedRow] != -1) {
        selectedEntity = [self.outlineView itemAtRow:self.outlineView.selectedRow];
    }
    [self.delegate entitiesViewController:self didSelectEntitiyDescription:selectedEntity];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![item isKindOfClass:[NSDictionary class]];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    BOOL isRootItem = [item isKindOfClass:[NSDictionary class]];
    if(isRootItem) {
        NSTextField *result = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        [result setStringValue:@"ENTITIES"];
        return result;
    }
    CDEEntityTableCellView *result = [outlineView makeViewWithIdentifier:@"EntityCell" owner:self];
    [[result.badgeButton cell] setHighlightsBy:0];
    NSEntityDescription *entity = item;
    [self updateUIOfEntityTableCellView:result withEntityDescription:entity];
    return result;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    BOOL isRootItem = [item isKindOfClass:[NSDictionary class]];
    if(isRootItem) {
        return @"ENTITIES";
    }
    return item;
}

- (void)updateUIOfEntityTableCellView:(CDEEntityTableCellView *)cell withEntityDescription:(NSEntityDescription *)entityDescription {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityDescription.name];
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:nil];
    [cell setBadgeValue:count];
    cell.textField.stringValue = entityDescription.nameForDisplay_cde;
}

@end
