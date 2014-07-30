#import <Cocoa/Cocoa.h>

@protocol CDEManagedObjectsViewControllerDelegate;

@class CDEManagedObjectsRequest;
@class CDERequestDataCoordinator;
@class CDEAutosaveInformation;

@interface CDEManagedObjectsViewController : NSViewController

#pragma mark - Properties
@property (nonatomic, weak) id<CDEManagedObjectsViewControllerDelegate> delegate;
@property (nonatomic, readonly) NSManagedObject *selectedManagedObject;
@property (nonatomic, readonly) NSArray *selectedManagedObjects;
@property (nonatomic, readonly, strong) CDERequestDataCoordinator *dataCoordinator;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, assign, getter = isBottomBarVisible) BOOL bottomBarVisible; // default: YES
@property (nonatomic, readonly, getter = canDeleteSelectedManagedObjects) BOOL canDeleteSelectedManagedObjects;
@property (nonatomic, readonly, getter = canInsertManagedObject) BOOL canInsertManagedObject;
@property (nonatomic, readonly, getter = canCreateCSVRepresentationWithSelectedObjects) BOOL canCreateCSVRepresentationWithSelectedObjects;
@property (assign) BOOL canNavigateThroughObjectGraph;

#pragma mark - Actions
- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

#pragma mark - Displaying Stuff
@property (nonatomic, weak) CDEAutosaveInformation *autosaveInformation;
@property (nonatomic, strong) CDEManagedObjectsRequest *request;
- (void)setRequest:(CDEManagedObjectsRequest *)request dataCoordinatorClass:(Class)dataCoordinatorClass;
- (void)setRequest:(CDEManagedObjectsRequest *)request dataCoordinator:(CDERequestDataCoordinator *)dataCoordinator;

#pragma mark - Selecting 
- (void)makeTableViewFirstResponder;

#pragma mark - UI
- (void)updateUIOfVisibleObjects;

@end
