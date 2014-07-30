#import <Foundation/Foundation.h>

@class CDEManagedObjectsRequest;
@class CDEManagedObjectsViewController;
@class CDEEntityAutosaveInformation;

@interface CDERequestDataCoordinator : NSObject

#pragma mark - Creating
- (id)initWithManagedObjectsRequest:(CDEManagedObjectsRequest *)request
                          tableView:(NSTableView *)tableView
                        searchField:(NSSearchField *)searchField
       managedObjectsViewController:(CDEManagedObjectsViewController *)managedObjectsViewController;

#pragma mark - Properties
@property (nonatomic, strong, readonly) CDEManagedObjectsRequest *request;
@property (nonatomic, weak, readonly) NSTableView *tableView;
@property (nonatomic, weak, readonly) NSSearchField *searchField;
@property (nonatomic, copy, readonly) NSPredicate *filterPredicate;
@property (nonatomic, weak, readonly) CDEManagedObjectsViewController *managedObjectsViewController;

#pragma mark - For Subclassers
// The default implementation returns columns for supported attributes, relationships and a column for the objectID
@property (nonatomic, copy, readonly) NSArray *tableColumns;

- (NSInteger)numberOfObjects;

// Returning nil is okay
- (id)objectValueForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSUInteger)index;

- (id)objectValueByTransformingObjectValue:(id)objectValue forTableColumn:(NSTableColumn *)tableColumn atIndex:(NSInteger)index;

- (NSManagedObject *)managedObjectAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfManagedObject:(NSManagedObject *)managedObject;

- (void)prepare;
- (void)invalidate;

- (NSManagedObject *)createAndAddManagedObject;
- (void)removeManagedObjectAtIndex:(NSUInteger)index;
- (NSIndexSet *)indexesOfSelectedManagedObjects;
- (NSArray *)selectedManagedObjects;
- (void)removeSelectedManagedObjects;

- (NSView *)viewForTableColumn:(NSTableColumn *)tableColumn atIndex:(NSInteger)atIndex;

- (IBAction)takeBoolValueFromSender:(id)sender;
- (void)controlTextDidEndEditing:(NSNotification *)notification;
- (void)binaryValueTextField:(NSTextField *)textField didChangeBinaryValue:(NSData *)binaryValue;
- (IBAction)relationshipBadgeButtonClicked:(id)sender;

#pragma mark - Special Shit
- (IBAction)showDatePickerForSender:(id)sender;
- (IBAction)showTextEditorForSender:(id)sender;

#pragma mark - For Subclassers / UI
- (void)updateUIOfVisibleObjects;

#pragma mark - For Subclassers / Searching
- (void)didChangeFilterPredicate;

#pragma mark - For Subclassers / Used to disable/enable the buttons
- (BOOL)canPerformAdd;
- (BOOL)canPerformDelete;

#pragma mark - Autosave
- (CDEEntityAutosaveInformation *)entityAutosaveInformation;

@end
