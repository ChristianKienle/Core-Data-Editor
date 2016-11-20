#import "CDEApplicationDelegate.h"
#import "CDENSNullToNilTransformer.h"
#import "CDENameToNameForDisplayValueTransformer.h"
#import "NSPersistentStore+CDEStoreAnalyzer.h"
#import "CDEConfiguration.h"
#import "CDEDocument.h"
#import "CDEAboutWindowController.h"
#import "NSWorkspace+CDEAdditions.h"
#import "CDEProjectBrowserWindowController.h"
#import "CDESetupWindowController.h"
#import "PreferencesWC.h"
@interface CDEApplicationDelegate () <NSApplicationDelegate>

#pragma mark - Helper / Security Scoped Resources
@property (nonatomic, copy) NSURL *iPhoneSimulatorDirectory;
@property (nonatomic, copy) NSURL *derivedDataDirectory;

#pragma mark - Properties
@property (nonatomic, strong) CDEAboutWindowController *aboutWindowController;
@property (nonatomic, strong) CDEProjectBrowserWindowController *projectBrowserWindowController;
@property (nonatomic, strong) CDESetupWindowController *setupWindowController;

@end

@implementation CDEApplicationDelegate

+ (void)initialize {
  if(self == [CDEApplicationDelegate class]) {
    [NSUserDefaults registerCoreDataEditorDefaults_cde];
    [NSValueTransformer setValueTransformer:[CDENSNullToNilTransformer new] forName:@"CDENSNullToNilTransformer"];
    [CDENameToNameForDisplayValueTransformer registerDefaultCoreDataEditorNameToNameForDisplayValueTransformer];
  }
}

#pragma mark - Actions
- (IBAction)showPreferences:(id)sender {
  PreferencesWC *vc = [[NSStoryboard storyboardWithName:@"Preferences" bundle:nil] instantiateInitialController];
  [vc showWindow:nil];
  //cde.showPreferences
}

- (IBAction)showAbout:(id)sender {
  [self.aboutWindowController showWindow:self];
}

- (IBAction)showHelp:(id)sender {
  [[NSWorkspace sharedWorkspace] openSupportWebsite_cde];
}

- (IBAction)showProjectBrowser:(id)sender {
  if(self.projectBrowserWindowController == nil) {
    self.projectBrowserWindowController = [CDEProjectBrowserWindowController new];
  }
  [self.projectBrowserWindowController showWithProjectDirectoryURL:self.iPhoneSimulatorDirectory];
}

#pragma mark NSApplicationDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [[NSNotificationCenter defaultCenter] addObserverForName:CDEUserDefaultsNotifications.didChangeSimulatorDirectory object:defaults queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    self.iPhoneSimulatorDirectory = defaults.simulatorDirectory_cde;
    [self.projectBrowserWindowController updateProjectDirectoryURL:self.iPhoneSimulatorDirectory];
  }];
  
  [[NSNotificationCenter defaultCenter] addObserverForName:CDEUserDefaultsNotifications.didChangeBuildProductsDirectory object:defaults queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    self.derivedDataDirectory = defaults.buildProductsDirectory_cde;
  }];
}
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if(defaults.applicationNeedsSetup_cde) {
    self.setupWindowController = [CDESetupWindowController new];
    [self.setupWindowController showWindow:self];
  }
  else if (defaults.opensProjectBrowserOnLaunch_cde) {
    [self showProjectBrowser:nil];
    
  }
  
  self.aboutWindowController = [[CDEAboutWindowController alloc] initWithWindowNibName:@"CDEAboutWindowController"];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if(!flag && defaults.opensProjectBrowserOnLaunch_cde) {
    [self showProjectBrowser:nil];
    return NO;
  }
  return YES;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
  return NO;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
  if([filename.pathExtension isEqualToString:@"coredataeditor5"]) {
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename] display:YES completionHandler:^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error) {
      
    }];
    return YES;
  }
  // Is this a store file?
  NSURL *storeURL = [NSURL fileURLWithPath:filename];
  
  NSString *storeType = [NSPersistentStore typeOfPersistentStoreAtURL_cde:storeURL];
  if(storeType == nil) {
    NSLog(@"'%@' not a valid store", filename);
    return NO;
  }
  // If we have no build products URL we can return NO
  NSURL *buildProductsDirectory = [[NSUserDefaults standardUserDefaults] buildProductsDirectory_cde];
  if(buildProductsDirectory == nil) {
    NSLog(@"no build products directory.");
    assert(false);
    return YES;
  }
  
  // Try to find a matching model
  NSFileManager *fileManager = [NSFileManager new];
  NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:buildProductsDirectory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
    NSLog(@"error while enumerating contents of build products directory: %@", error);
    return YES;
  }];
  
  NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
  
  for(NSURL *potentialModelURL in enumerator) {
    NSError *error = nil;
    NSString *UTI = [workspace typeOfFile:potentialModelURL.path error:&error];
    if(UTI == nil) {
      NSLog(@"Failed to determine UTI: %@", error);
      continue;
    }
    BOOL conformsTo = [workspace type:UTI conformsToType:@"com.apple.xcode.mom"];
    if(!conformsTo) {
      continue;
    }
    
    // We have found a model!
    NSURL *modelURL = potentialModelURL;
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSManagedObjectModel *transformedModel = model.transformedManagedObjectModel_cde;
    
    // Test compatibility
    error = nil;
    BOOL isCompatible = [transformedModel isCompatibleWithStoreAtURL:storeURL error_cde:&error];
    if(!isCompatible) {
      continue;
    }
    error = nil;
    
    // We have found something!
    NSLog(@"%@ is compatible with %@", storeURL.lastPathComponent, modelURL);
    CDEDocument *document = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:NO error:NULL];
    CDEConfiguration *configuration = [document createConfiguration];
    [configuration setApplicationBundleURL:nil storeURL:storeURL modelURL:modelURL];
    error = nil;
    [document makeWindowControllers];
    [document showWindows];
    return YES;
  }
  return NO;
}

@end
