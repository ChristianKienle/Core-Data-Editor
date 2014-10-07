#import "CDEManagedObjectsViewController.h"
#import "CDEManagedObjectsViewControllerDelegate.h"
#import "CDEManagedObjectsRequest.h"
#import "CDEManagedObjectsPicker.h"
#import "CDEEntityAutosaveInformationItem.h"
#import "CDEEntityAutosaveInformation.h"
#import "CDEAutosaveInformation.h"

// Cells: Begin
#import "CDEStringValueTableCellView.h"
#import "CDEBoolValueTableCellView.h"
#import "CDEObjectIDValueTableCellView.h"
#import "CDEFloatingPointValueTableCellView.h"
#import "CDEBinaryValueTableCellView.h"
#import "CDEToManyRelationshipTableCellView.h"
#import "CDEIntegerValueTableCellView.h"
// Cells: End

// Additions: Begin
#import "NSSortDescriptor+CDEAdditions.h"
#import "NSTableCellView+JKNibLoading.h"
#import "NSTableView+CDEAdditions.h"
// Additions: End

// Coordinator: Begin
#import "CDERequestDataCoordinator.h"
#import "CDEEntityRequestDataCoordinator.h"
#import "CDEOrderedRelationshipRequestDataCoordinator.h"
#import "CDEUnorderedRelationshipRequestDataCoordinator.h"
#import "CDEToOneRelationshipRequestDataCoordinator.h"
// Coordinator: End

#import "CDEMenuItem.h"
#import "CDEMenuWindowController.h"
#import "BFViewController.h"

@interface CDEManagedObjectsViewController () <NSTableViewDelegate, NSTableViewDataSource, CDEBinaryValueTableCellViewDelegate, BFViewController>

#pragma mark - Properties
@property (nonatomic, readwrite, strong) CDERequestDataCoordinator *dataCoordinator;
@property (nonatomic, weak) IBOutlet NSView *bottomBarView;
@property (nonatomic, weak) IBOutlet NSButton *addButton;
@property (nonatomic, weak) IBOutlet NSButton *removeButton;
@property (nonatomic, weak) IBOutlet NSMenuItem *createManagedObjectMenuItem;
@property (nonatomic, strong) NSMenu *addButtonMenu;
@property (nonatomic, strong) IBOutlet NSView *bottomBarViewWithNoParent;
@property (nonatomic, strong) CDEManagedObjectsPicker *managedObjectsPicker;
@property (strong) CDEMenuWindowController *relationshipsMenuWindowController;

@end

@implementation CDEManagedObjectsViewController

#pragma mark - Working with the Delegate
- (void)managedObjectsViewControllerDidChangeContents {
  if(self.delegate == nil) {
    return;
  }
  
  if([self.delegate respondsToSelector:@selector(managedObjectsViewControllerDidChangeContents:)] == NO) {
    return;
  }
  
  [self.delegate managedObjectsViewControllerDidChangeContents:self];
}

#pragma mark - Working with the UI
- (void)updateAddAndRemoveButtons {
  if(self.dataCoordinator == nil) {
    [self.addButton setEnabled:NO];
    [self.removeButton setEnabled:NO];
    [self.createManagedObjectMenuItem setEnabled:NO];
    return;
  }
  [self.addButton setEnabled:YES];
  [self.removeButton setEnabled:[self.dataCoordinator canPerformDelete]];
  [self.createManagedObjectMenuItem setEnabled:[self.dataCoordinator canPerformAdd]];
  if(self.request.isEntityRequest) {
    self.addButton.menu = nil;
  } else {
    self.addButton.menu = self.addButtonMenu;
  }
  
}

#pragma mark - Creating
- (id)init {
  return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _bottomBarVisible = YES;
    self.canNavigateThroughObjectGraph = NO;
  }
  return self;
}

- (void)loadView {
  [super loadView];
  self.addButtonMenu = self.addButton.menu;
  
  self.managedObjectsPicker = [CDEManagedObjectsPicker new];
  NSArray *columns = [self.tableView tableColumns];
  NSTableColumn *standardColumn = [columns lastObject];
  [self.tableView removeTableColumn:standardColumn];
  [self unregisterAllNibs];
  [self updateAddAndRemoveButtons];
  
//  [[self.searchField cell] setControlSize:NSMiniControlSize];
//  [self.searchField setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]]];
  NSRect searchFrame = [self.searchField frame];
  NSSize cellSize = [[self.searchField cell] cellSizeForBounds:searchFrame];
  searchFrame.size.height = cellSize.height;
  [self.searchField setFrame:searchFrame];
  
  [self.tableView setDoubleAction:@selector(showRelationshipFor:)];
  [self.tableView setTarget:self];
}

- (void)unregisterAllNibs {
  NSArray *identifiers = [[self.tableView registeredNibsByIdentifier] allKeys];
  for(NSString *identifier in identifiers) {
    [self.tableView registerNib:nil forIdentifier:identifier];
  }
}

#pragma mark - Properties
- (NSManagedObject *)selectedManagedObject {
  NSInteger row = self.tableView.selectedRow;
  if(row == -1) {
    return nil;
  }
  NSManagedObject *result = [self.dataCoordinator managedObjectAtIndex:row];
  return result;
}

- (NSArray *)selectedManagedObjects {
  return [self.dataCoordinator selectedManagedObjects];
}

- (void)setBottomBarVisible:(BOOL)bottomBarVisible {
  _bottomBarVisible = bottomBarVisible;
  if(self.bottomBarVisible) {
    if(self.bottomBarView != nil) {
      // do nothing
      return;
    } else {
      // show the bottomBarView
      self.bottomBarView = self.bottomBarViewWithNoParent;
      
      // Adjust scroll view frame
      NSRect newScrollViewFrame = self.tableView.enclosingScrollView.frame;
      newScrollViewFrame.size.height -= NSHeight(self.bottomBarView.frame);
      newScrollViewFrame.origin.y += NSHeight(self.bottomBarView.frame);
      self.tableView.enclosingScrollView.frame = newScrollViewFrame;
      
      // Adjust bottom bar frame
      NSRect bottomBarFrame = NSZeroRect;
      bottomBarFrame.size.width = NSWidth(self.view.bounds);
      self.bottomBarView.frame = bottomBarFrame;
      [self.view addSubview:self.bottomBarView];
    }
  } else { // bottom bar shoul be hidden
    if(self.bottomBarView == nil) {
      return; // do nothing
    } else {
      // hide the bottomBarView
      self.bottomBarViewWithNoParent = self.bottomBarView;
      [self.bottomBarView removeFromSuperview];
      self.bottomBarView = nil;
      NSRect newScrollViewFrame = self.tableView.enclosingScrollView.frame;
      newScrollViewFrame.size.height += NSHeight(self.bottomBarViewWithNoParent.frame);
      newScrollViewFrame.origin.y -= NSHeight(self.bottomBarViewWithNoParent.frame);
      self.tableView.enclosingScrollView.frame = newScrollViewFrame;
      
    }
  }
}

- (BOOL)canCreateCSVRepresentationWithSelectedObjects {
  return self.dataCoordinator != nil && self.dataCoordinator.indexesOfSelectedManagedObjects != nil && self.dataCoordinator.indexesOfSelectedManagedObjects.count > 0;
}

- (BOOL)canDeleteSelectedManagedObjects {
  return self.dataCoordinator.canPerformDelete;
}

- (BOOL)canInsertManagedObject {
  return self.dataCoordinator.canPerformAdd;
}

#pragma mark - Actions
- (IBAction)add:(id)sender {
  NSManagedObject *addedObject = [self.dataCoordinator createAndAddManagedObject];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if(defaults.automaticallyResolvesValidationErrors_cde) {
    [self.request.managedObjectContext makeManagedObjectValid:addedObject];
  }
  [self updateAddAndRemoveButtons];
  [self managedObjectsViewControllerDidChangeContents];
  NSInteger row = [self.dataCoordinator indexOfManagedObject:addedObject];
  [self.tableView scrollRowToVisible:row];
}

- (IBAction)remove:(id)sender {
  [self.dataCoordinator removeSelectedManagedObjects];
  [self updateAddAndRemoveButtons];
  [self managedObjectsViewControllerDidChangeContents];
}

- (IBAction)showManagedObjectsPicker:(id)sender {
  id selectedManagedObjects = [NSSet set];
  if(self.request.relatedObjects != nil) {
    selectedManagedObjects = self.request.relatedObjects;
  }
  [self.managedObjectsPicker displayObjectsOfEntityDescription:self.request.entityDescription
                                        selectedManagedObjects:selectedManagedObjects
                                          managedObjectContext:self.request.managedObjectContext
                                       allowsMultipleSelection:YES
                                            showRelativeToRect:self.addButton.bounds
                                                        ofView:self.addButton
                                             completionHandler:^(id pickedObjects) {
                                               [self.request.managedObject setValue:pickedObjects forKey:self.request.relationshipDescription.name];
                                               [self updateAddAndRemoveButtons];
                                               [self managedObjectsViewControllerDidChangeContents];
                                               [self.tableView reloadData];
                                             }];
}


#pragma mark - Displaying Stuff
- (void)setRequest:(CDEManagedObjectsRequest *)request {
  [self setRequest:request dataCoordinatorClass:Nil];
}

- (void)setRequest:(CDEManagedObjectsRequest *)request dataCoordinatorClass:(Class)dataCoordinatorClass {
  CDERequestDataCoordinator *dataCoordinator = nil;
  if(dataCoordinatorClass != Nil) {
    dataCoordinator = [[dataCoordinatorClass alloc] initWithManagedObjectsRequest:request tableView:self.tableView searchField:self.searchField managedObjectsViewController:self];
  }
  [self setRequest:request dataCoordinator:dataCoordinator];
}

- (void)setRequest:(CDEManagedObjectsRequest *)request dataCoordinator:(CDERequestDataCoordinator *)dataCoordinator {
  // Hack: We have to make sure to end editing before setting the new request.
  // Otherwhise -controlTextDidEndEditing: will get called after we have modified the table view
  // and exchanged the data coordinator.
  //    if(![self.view.window makeFirstResponder:self.view.window]) {
  //        [self.view.window endEditingFor:nil];
  //    }
  
  if(self.request.entityDescription.name != nil) {
    CDEEntityAutosaveInformation *information = [self.dataCoordinator entityAutosaveInformation];
    [self.autosaveInformation setInformation:information forEntityNamed:self.request.entityDescription.name];
  }
  
  _request = request;
  [self.tableView removeAllTableColumns_cde];
  
  [self.dataCoordinator invalidate];
  self.dataCoordinator = nil;
  
  CDERequestDataCoordinator *resultingDataCoordinator = nil;
  
  if(dataCoordinator != nil) {
    resultingDataCoordinator = dataCoordinator;
  } else {
    resultingDataCoordinator = [self newRequestDataCoordinatorWithRequest:request];
  }
  
  self.dataCoordinator = resultingDataCoordinator;
  
  [self.dataCoordinator prepare];
  [self.tableView beginUpdates];
  [self.tableView addTableColumns_cde:self.dataCoordinator.tableColumns];
  [self.tableView reloadData];
  [self.tableView endUpdates];
  [self updateAddAndRemoveButtons];
}

- (CDERequestDataCoordinator *)newRequestDataCoordinatorWithRequest:(CDEManagedObjectsRequest *)request {
  if(request == nil) {
    return nil;
  }
  Class class = Nil;
  if(request.isEntityRequest || request.isFetchRequest) {
    class = [CDEEntityRequestDataCoordinator class];
  }
  if(request.isRelationshipRequest) {
    if(request.relationshipDescription.isToOne_cde) {
      class = [CDEToOneRelationshipRequestDataCoordinator class];
    } else {
      if(request.relationshipDescription.isOrdered == NO) {
        class = [CDEUnorderedRelationshipRequestDataCoordinator class];
      }
      else {
        class = [CDEOrderedRelationshipRequestDataCoordinator class];
      }
    }
  }
  
  NSAssert(class != Nil, @"Nil class not valid.");
  
  return [[class alloc] initWithManagedObjectsRequest:request
                                            tableView:self.tableView
                                          searchField:self.searchField
                         managedObjectsViewController:self];
}

#pragma mark - Selecting
- (void)makeTableViewFirstResponder {
  [self.tableView.window makeFirstResponder:self.tableView];
}

#pragma mark - UI
- (void)updateUIOfVisibleObjects {
  [self.dataCoordinator updateUIOfVisibleObjects];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [self.dataCoordinator numberOfObjects];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
  id objectValue = [self.dataCoordinator objectValueForTableColumn:tableColumn atIndex:rowIndex];
  id result = [self.dataCoordinator objectValueByTransformingObjectValue:objectValue forTableColumn:tableColumn atIndex:rowIndex];
  return result;
}

#pragma mark - NSTableViewDelegate
- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView {
  return YES;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)rowIndex {
  return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  [self updateAddAndRemoveButtons];
  if(self.delegate == nil) {
    return;
  }
  if([self.delegate respondsToSelector:@selector(managedObjectsViewController:didSelectManagedObject:)] == NO) {
    return;
  }
  NSInteger selectedRow = [self.tableView selectedRow];
  NSManagedObject *selectedManagedObject = nil;
  if(selectedRow != -1) {
    selectedManagedObject = [self.dataCoordinator managedObjectAtIndex:selectedRow];
  }
  [self.delegate managedObjectsViewController:self didSelectManagedObject:selectedManagedObject];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  return [self.dataCoordinator viewForTableColumn:tableColumn atIndex:row];
}

- (void)tableViewColumnDidMove:(NSNotification *)notification {
  if(self.request.entityDescription.name != nil) {
    CDEEntityAutosaveInformation *information = [self.dataCoordinator entityAutosaveInformation];
    [self.autosaveInformation setInformation:information forEntityNamed:self.request.entityDescription.name];
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(managedObjectsViewControllerDidChangeAutosaveInformation:)]) {
      [self.delegate managedObjectsViewControllerDidChangeAutosaveInformation:self];
    }
  }
}

- (void)tableViewColumnDidResize:(NSNotification *)notification {
  if(self.request.entityDescription.name != nil) {
    CDEEntityAutosaveInformation *information = [self.dataCoordinator entityAutosaveInformation];
    [self.autosaveInformation setInformation:information forEntityNamed:self.request.entityDescription.name];
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(managedObjectsViewControllerDidChangeAutosaveInformation:)]) {
      [self.delegate managedObjectsViewControllerDidChangeAutosaveInformation:self];
    }
  }
}

#pragma mark - Cells
- (IBAction)takeBoolValueFromSender:(id)sender {
  [self.dataCoordinator takeBoolValueFromSender:sender];
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification {
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
  [self.dataCoordinator controlTextDidEndEditing:notification];
}

- (void)binaryValueTextField:(NSTextField *)textField didChangeBinaryValue:(NSData *)binaryValue {
  [self.dataCoordinator binaryValueTextField:textField didChangeBinaryValue:binaryValue];
}

- (IBAction)relationshipBadgeButtonClicked:(id)sender {
  [self.dataCoordinator relationshipBadgeButtonClicked:sender];
}

#pragma mark - Special Shit
- (IBAction)showDatePickerForSender:(id)sender {
  [self.dataCoordinator showDatePickerForSender:sender];
}
- (IBAction)showTextEditorForSender:(id)sender {
  [self.dataCoordinator showTextEditorForSender:sender];
}

#pragma mark - Traverse UI
- (void)showRelationshipFor:(id)sender {
  if(self.canNavigateThroughObjectGraph == NO) {
    return;
  }
  NSInteger clickedRow = [self.tableView clickedRow];
  if(clickedRow == -1) {
    return;
  }
  NSManagedObject *clickedManagedObject = [self.dataCoordinator managedObjectAtIndex:clickedRow];
  NSEntityDescription *entity = clickedManagedObject.entity;
  NSDictionary *relationshipsByName = [entity relationshipsByName];
  if(relationshipsByName.count == 0) {
    return;
  }
  
  NSMutableArray *menuItems = [NSMutableArray array];
  for(NSString *relationshipName in relationshipsByName) {
    NSRelationshipDescription *relationship = [relationshipsByName objectForKey:relationshipName];
    NSString *badgeValue = [self badgeValueForManagedObject:clickedManagedObject relationshipDescription:relationship];
    CDEMenuItem *relationshipItem = [[CDEMenuItem alloc] initWithTitle:relationshipName target:self action:@selector(showObjectsForRelationship:) representedObject:relationship badgeValue:badgeValue showsBadge:YES];
    [menuItems addObject:relationshipItem];
  }
  NSPoint attachToPoint = [self.view.window mouseLocationOutsideOfEventStream];
  self.relationshipsMenuWindowController = [[CDEMenuWindowController alloc] initWithMenuItems:menuItems size:NSMakeSize(300, 100)];
  attachToPoint = [self.tableView convertPoint:attachToPoint fromView:nil];
  NSRect rect = NSMakeRect(attachToPoint.x, attachToPoint.y, 10, 10);
  //NSRect rect = [self.tableView rectOfRow:clickedRow];
  [self.relationshipsMenuWindowController showRelativeToRect:rect ofView:self.tableView preferredEdge:NSMinYEdge];
  //   [self.relationshipsMenuWindowController showWindow];
  
}

- (NSString *)badgeValueForManagedObject:(NSManagedObject *)managedObject relationshipDescription:(NSRelationshipDescription *)relationshipDescription {
  id valueForRelationship = [managedObject valueForKey:relationshipDescription.name];
  NSArray *countArray = [NSArray array];
  if(valueForRelationship == nil) {
    countArray = [NSArray array];
  }
  if(relationshipDescription.isToMany && valueForRelationship != nil) {
    countArray = [valueForRelationship allObjects];
  }
  if(relationshipDescription.isToMany == NO && valueForRelationship != nil) {
    countArray = [NSArray arrayWithObject:valueForRelationship];
  }
  return [NSString stringWithFormat:@"%lu", countArray.count];
}

- (void)showObjectsForRelationship:(id)sender {
  // sender is a CDEMenuItem whose representedObject is a NSRelationshipDescription
  if(self.delegate == nil) {
    return;
  }
  if([self.delegate respondsToSelector:@selector(managedObjectsViewController:didSelectRelationship:ofManagedObject:)] == NO) {
    return;
  }
  NSManagedObject *selectedManagedObject = self.selectedManagedObject;
  NSRelationshipDescription *relationship = [sender representedObject];
  [self.delegate managedObjectsViewController:self didSelectRelationship:relationship ofManagedObject:selectedManagedObject];
}

#pragma mark - BFViewController Implementation
-(void)viewWillAppear: (BOOL)animated
{
}

-(void)viewDidAppear: (BOOL)animated
{
}

-(void)viewWillDisappear: (BOOL)animated
{
}

-(void)viewDidDisappear: (BOOL)animated
{
}


@end
