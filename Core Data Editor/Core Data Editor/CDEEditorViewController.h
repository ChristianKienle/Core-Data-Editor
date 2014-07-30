#import <Cocoa/Cocoa.h>

@class CDEConfiguration;
@class CDEAutosaveInformation;
@interface CDEEditorViewController : NSViewController

#pragma mark - Displaying a Configuration
- (BOOL)setConfiguration:(CDEConfiguration *)configuration modelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL needsReload:(BOOL)needsReload error:(NSError **)error;

#pragma mark - Saving
- (BOOL)save:(NSError **)error;

#pragma mark - State
- (void)cleanup;

#pragma mark - Query Control
- (IBAction)takeQueryFromSender:(id)sender;

#pragma mark - Entity Operations
- (IBAction)deleteSelectedObjcts:(id)sender;
- (IBAction)insertObject:(id)sender;
- (IBAction)copySelectedObjectsAsCSV:(id)sender;
@property (nonatomic, readonly, getter = canCreateCSVRepresentationWithSelectedObjects) BOOL canCreateCSVRepresentationWithSelectedObjects;
@property (nonatomic, readonly, getter = canDeleteSelectedManagedObjects) BOOL canDeleteSelectedManagedObjects;
@property (nonatomic, readonly, getter = canInsertManagedObject) BOOL canInsertManagedObject;
@property (nonatomic, strong, readonly) CDEAutosaveInformation *autosaveInformation;

#pragma mark - Importing/Exporting
- (IBAction)showImportCSVFileWindow:(id)sender;

@end
