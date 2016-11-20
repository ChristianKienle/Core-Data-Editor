#import "CDEProjectBrowserWindowController.h"
#import "CDEProjectBrowserItem.h"
#import "CDEDocument.h"
#import "CDEConfiguration.h"
#import "CDEApplicationDelegate.h"
#import "NSURL+CDEAdditions.h"
#import "NSDirectoryEnumerator+ProjectBrowser.h"

#define kCDEFileModificationDateKey @"modificationDate"
#define kCDEStorePathKey @"storePath"
#define kCDEModelPathKey @"modelPath"

typedef void(^ProjectBrowserReloadCompletionHandler)(NSArray *projectBrowserItems /* CDEProjectBrowserItem */);

@interface _ProjectBrowserItem: NSObject

@property (copy) NSString *modificationDate;
@property (copy) NSString *storePath;
@property (copy) NSString *modelPath;
@end

@implementation _ProjectBrowserItem

- (instancetype)initWithModificationDate:(NSString *)modificationDate storePath:(NSString *)storePath modelPath:(NSString *)modelPath {
  self = [super init];
  self.modificationDate = modificationDate;
  self.storePath = storePath;
  self.modelPath = modelPath;
  return self;
}

- (instancetype)init {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the class _Project"
                               userInfo:nil];
}

@end



@interface CDEProjectBrowserWindowController ()

#pragma mark - Properties
@property (copy) NSURL *projectDirectoryURL;

@property (strong) IBOutlet NSProgressIndicator *reloadProgressIndicator;
@property (strong) IBOutlet NSButton *reloadButton;

@property (strong) IBOutlet NSArrayController *items;
@property (strong) IBOutlet NSTableView *tableView;

@end

@implementation CDEProjectBrowserWindowController

#pragma mark - Working with the project browser
- (void)showWithProjectDirectoryURL:(NSURL *)projectDirectoryURL {
  self.projectDirectoryURL = projectDirectoryURL;
  [self showWindow:self];
  [self updateUI];
  [self reloadProjectBrowser:self];
}

- (void)updateProjectDirectoryURL:(NSURL *)projectDirectoryURL {
  self.projectDirectoryURL = projectDirectoryURL;
  [self reloadProjectBrowser:self];
}

- (void)updateUI {
  [self.reloadButton setEnabled:(self.projectDirectoryURL != nil)];
}

#pragma mark - Actions
- (IBAction)createProject:(id)sender {
  NSInteger row = [self.tableView rowForView:sender];
  if(row == -1) {
    return;
  }
  CDEProjectBrowserItem *item = [self.items.arrangedObjects objectAtIndex:row];
  
  if(item == nil) {
    return;
  }
  CDEDocument *document = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:NO error:NULL];
  CDEConfiguration *configuration = [document createConfiguration];
  NSError *error = nil;
  NSURL *storeURL = [NSURL fileURLWithPath:item.storePath];
  NSURL *modelURL = [NSURL fileURLWithPath:item.modelPath];
  
  [configuration setApplicationBundleURL:nil storeURL:storeURL modelURL:modelURL];
  
  error = nil;
  [document makeWindowControllers];
  [document showWindows];
}

- (void)prepareUIForReload {
  [self.items setContent:[@[] mutableCopy]];
  [self.reloadButton setEnabled:NO];
  [self.reloadProgressIndicator startAnimation:self];
}

- (void)performReloadWithCompletionHandler:(ProjectBrowserReloadCompletionHandler)completionHandler {
  NSParameterAssert(completionHandler);
  NSAssert(self.projectDirectoryURL != nil, @"");
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSDirectoryEnumerator *enumerator = [self newSimulatorDirectoryEnumerator];
    
    NSDictionary *metadataByStorePath;
    NSDictionary *modelByModelPath;
    
    [enumerator getMetadataByStorePath:&metadataByStorePath modelByModelPath:&modelByModelPath];
    
    NSArray *items = [self compatibleProjectBrowserItemsWithMetadataByStorePath:metadataByStorePath modelByModelPath:modelByModelPath];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      completionHandler(items);
    });
  });
}



- (NSArray<CDEProjectBrowserItem*> *)compatibleProjectBrowserItemsWithMetadataByStorePath:(NSDictionary<NSString*, NSDictionary*> *)metadataByStorePath modelByModelPath:(NSDictionary<NSString*, NSManagedObjectModel*>*)modelByModelPath {
  NSMutableArray<CDEProjectBrowserItem*> *items = [NSMutableArray new];
  NSMutableArray<_ProjectBrowserItem*> *projectItems = [NSMutableArray new];
  // Find compatible combinations
  [modelByModelPath enumerateKeysAndObjectsUsingBlock:^(NSString *modelPath, NSManagedObjectModel *model, BOOL *stop) {
    [metadataByStorePath enumerateKeysAndObjectsUsingBlock:^(NSString *storePath, NSDictionary *metadata, BOOL *stop) {
      BOOL isCompatible = [model isConfiguration:nil compatibleWithStoreMetadata:metadata];
      if(isCompatible) {
        NSDate *storeModDate;
        NSURL *storeURL=[NSURL fileURLWithPath:storePath];
        NSError *error;
        [storeURL getResourceValue:&storeModDate forKey:NSURLContentModificationDateKey error:&error];
        
        //Also look for: .sqlite-wal (write-ahead log).  Use most recent, although the wal should be most recent if found.
        NSString *walPath=[NSString stringWithFormat:@"%@-wal",storeURL.absoluteString];
        NSURL *walUrl=[NSURL URLWithString:walPath];
        NSDate *walModDate;
        [walUrl getResourceValue:&walModDate forKey:NSURLContentModificationDateKey error:&error];
        
        if ([storeModDate compare:walModDate]==NSOrderedAscending) {
          storeModDate=walModDate;
        }
        
        NSDate *modelModDate;
        NSURL *modelURL=[NSURL fileURLWithPath:modelPath];
        [modelURL getResourceValue:&modelModDate forKey:NSURLContentModificationDateKey error:&error];
        
        //NSSortDescriptor doesn't do NSDate, so use a string. Both dates concatenated for nesting.
        NSString *fileModDateString = [NSString stringWithFormat:@"%@ - %@",storeModDate, modelModDate];
        
        _ProjectBrowserItem *item = [[_ProjectBrowserItem alloc] initWithModificationDate:fileModDateString storePath:storePath modelPath:modelPath];
        
        [projectItems addObject:item];
      }
    }];
  }];
  //Now sort and display
  NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:kCDEFileModificationDateKey ascending:NO];
  NSArray<_ProjectBrowserItem*> *itemsSorted = [projectItems sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
  
  for (_ProjectBrowserItem *item in itemsSorted) {
    NSString *storePath = item.storePath;
    NSString *modelPath = item.modelPath;
    CDEProjectBrowserItem *item = [[CDEProjectBrowserItem alloc] initWithStorePath:storePath modelPath:modelPath];
    [items addObject:item];
  }
  
  return items;
}

- (NSDirectoryEnumerator *)newSimulatorDirectoryEnumerator {
  NSFileManager *fileManager = [NSFileManager defaultManager]; // there is no reason not to use the defaultManager
  NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:self.projectDirectoryURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
    NSLog(@"error while enumerating contents of simulator directory: %@", error);
    return YES;
  }];
  return enumerator;
}

- (IBAction)reloadProjectBrowser:(id)sender {
  NSURL *simulatorURL = self.projectDirectoryURL;
  if(simulatorURL == nil) {
    NSLog(@"simulator url is nil");
    [self displayDelayedNoSimulatorDirectoryAlert];
    return;
  }
  
  [self prepareUIForReload];
  
  [self performReloadWithCompletionHandler:^(NSArray *projectBrowserItems) {
    [self.items setContent:projectBrowserItems];
    [self.reloadButton setEnabled:YES];
    [self.reloadProgressIndicator stopAnimation:self];
  }];
}

#pragma mark - Helper
- (void)displayDelayedNoSimulatorDirectoryAlert {
  double delayInSeconds = 2.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"iPhone Simulator Directory not set";
    alert.informativeText = @"The Project Browser has to know where the iPhone Simulator directory is. Please go to the preferences and specify your iPhone Simulator directory in the Integration tab.";
    [alert addButtonWithTitle:@"Open Preferences…"];
    [alert addButtonWithTitle:@"Close Project Browser"];
    alert.alertStyle = NSAlertStyleInformational;
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
      if(returnCode ==  NSAlertFirstButtonReturn) {
        // show prefs.
        [(CDEApplicationDelegate *)[NSApp delegate] showPreferences:self];
      }
      [self closeWindowSoon];
    }];
  });
}

- (void)closeWindowSoon {
  double delayInSeconds = 2.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self.window performClose:self];
  });
}

#pragma mark - NSWindowController
- (instancetype)init {
  self = [super initWithWindowNibName:@"CDEProjectBrowserWindowController" owner:self];
  if(self) {
    
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
}

@end
