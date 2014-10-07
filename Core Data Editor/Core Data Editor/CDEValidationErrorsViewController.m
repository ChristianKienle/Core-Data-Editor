#import "CDEValidationErrorsViewController.h"
#import "CDEAttributeEditor.h"
#import "NSError+CDEValidation.h"

@interface NSManagedObjectContext (CDEValidationErrorsViewController)
@property (nonatomic, readonly) NSSet *changedObjects_cde;
@property (nonatomic, readonly) NSDictionary *validationErrorsByManagedObjectURI_cde;

@end
@implementation NSManagedObjectContext (CDEValidationErrorsViewController)
- (NSSet *)changedObjects_cde {
    NSMutableSet *result = [NSMutableSet new];
    [result unionSet:self.insertedObjects];
    [result unionSet:self.updatedObjects];
    [result unionSet:self.deletedObjects];
    return result;
}
- (NSDictionary *)validationErrorsByManagedObjectURI_cde {
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSSet *changedObjects = self.changedObjects_cde;
    for(NSManagedObject *object in changedObjects) {
        NSArray *errors = object.validationErrors_cde;
        if(errors == nil) {
            continue;
        }
        result[object.objectID.URIRepresentation] = errors;
    }
    return result;
}
- (NSArray *)validationErrorsByManagedObjectURIInArray_cde {
    NSMutableArray *result = [NSMutableArray new];
    
    NSDictionary *validationErrorsByManagedObjectURI = [self validationErrorsByManagedObjectURI_cde];
    [validationErrorsByManagedObjectURI enumerateKeysAndObjectsUsingBlock:^(NSURL *URI, NSArray *errors, BOOL *stop) {
        NSDictionary *entry = @{ @"URI" : URI, @"errors" : errors };
        [result addObject:entry];
    }];
    
    return result;
}
@end

/* [
      { URI : []}, 
      { URI : []}, ...
   ]
*/
@interface CDEValidationErrorsViewController () <NSTableViewDataSource, NSTableViewDelegate>

#pragma mark - Properties
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, copy) NSArray *tableContents;
@property (nonatomic, strong) CDEAttributeEditor *attributeEditor;

@end

@implementation CDEValidationErrorsViewController

#pragma mark - Creating
- (id)init {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.tableContents = @[];
        self.attributeEditor = [CDEAttributeEditor new];
        __typeof__(self) __weak weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            if([notification.object isEqual:weakSelf.managedObjectContext]) {
                __block NSMutableArray *tableContents = [NSMutableArray new];
                
                NSDictionary *validationErrorsByManagedObjectURI = [weakSelf.managedObjectContext validationErrorsByManagedObjectURI_cde];
                [validationErrorsByManagedObjectURI enumerateKeysAndObjectsUsingBlock:^(NSURL *URI, NSArray *errors, BOOL *stop) {

                    [tableContents addObject:URI];
                    [tableContents addObjectsFromArray:errors];

                }];
                
                weakSelf.tableContents = tableContents;
                [weakSelf.tableView reloadData];
                [self.tabView selectTabViewItemAtIndex:(tableContents.count == 0 ? 1 : 0)];
            }
        }];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    self.tableView.floatsGroupRows = NO;
  //self.view.allowsVibrancy = YES;
}

#pragma mark - Private
- (NSError *)errorAtRow:(NSInteger)row {
    if(row == -1) {
        return nil;
    }
    if(row >= self.tableContents.count) {
        return nil;
    }
    id result = self.tableContents[row];
    BOOL isError = [result isKindOfClass:[NSError class]];
    if(isError == NO) {
        return nil;
    }
    return result;
}

#pragma mark - NSTableViewDataSource/Delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.tableContents.count;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    id object = self.tableContents[row];
    return [object isKindOfClass:[NSError class]] == NO;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    id object = self.tableContents[row];
    BOOL objectIsError = [object isKindOfClass:[NSError class]];
    NSView *view = nil;
    if(objectIsError) {
        NSTableCellView *cell = (NSTableCellView *)[self.tableView makeViewWithIdentifier:@"ErrorCell" owner:self];
        view = cell;
    } else {
        NSTableCellView *cell = (NSTableCellView *)[self.tableView makeViewWithIdentifier:@"ObjectCell" owner:self];
        view = cell;
    }
    return view;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    id object = self.tableContents[row];
    BOOL objectIsError = [object isKindOfClass:[NSError class]];
    if(objectIsError) {
        return object;
    }
    NSManagedObjectID *ID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:object];
    
    return [ID humanReadableRepresentationByHidingEntityName_cde:NO];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)row {
    id object = self.tableContents[row];
    return [object isKindOfClass:[NSError class]];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSError *selectedError = [self errorAtRow:self.tableView.selectedRow];
    if(selectedError == nil) {
        return;
    }
    BOOL isSupported = selectedError.isSupportedValidationError_cde;
    if(isSupported == NO) {
        return;
    }
    if(self.attributeEditor.isShown) {
//        [self.attributeEditor close];
    }
    NSAttributeDescription *attribute = selectedError.invalidAttribute_cde;
    NSManagedObject *managedObject = selectedError.invalidManagedObject_cde;
    [self.attributeEditor showEditorForManagedObject:managedObject attributeDescription:attribute showRelativeToRect:[self.tableView rectOfRow:self.tableView.selectedRow] ofView:self.tableView completionHandler:^{
        
    }];
    
}

#pragma mark - Dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

@end
