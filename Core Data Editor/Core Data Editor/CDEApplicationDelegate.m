#import "CDEApplicationDelegate.h"
#import "CDEPreferencesWindowController.h"
#import "CDENSNullToNilTransformer.h"
#import "CDENameToNameForDisplayValueTransformer.h"
#import "NSPersistentStore+CDEStoreAnalyzer.h"
#import "CDEConfiguration.h"
#import "CDEDocument.h"
#import "CDEAboutWindowController.h"
#import "NSWorkspace+CDEAdditions.h"
#import "CDEProjectBrowserWindowController.h"
#import "CDESetupWindowController.h"

@interface CDEApplicationDelegate () <NSApplicationDelegate>

#pragma mark - Helper / Security Scoped Resources
@property (nonatomic, copy) NSURL *iPhoneSimulatorDirectory;
@property (nonatomic, copy) NSURL *derivedDataDirectory;

#pragma mark - Properties
@property (nonatomic, strong) CDEPreferencesWindowController *preferencesWindowController;
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
    [self.preferencesWindowController showWithCompletionHandler:^{
    }];
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

#pragma mark - Helper
#pragma mark - Helper / Security Scoped Resources
- (BOOL)startAccessingCoreDataEditorSecurityScopedResources {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    BOOL iPhoneSimulatorSuccess = YES;

    if(defaults.simulatorDirectory_cde != nil) {
        self.iPhoneSimulatorDirectory = defaults.simulatorDirectory_cde;
        iPhoneSimulatorSuccess = [self.iPhoneSimulatorDirectory startAccessingSecurityScopedResource];
    }

    BOOL buildProductsDirectorySuccess = YES;

    if(defaults.buildProductsDirectory_cde != nil) {
        self.derivedDataDirectory = defaults.buildProductsDirectory_cde;
        buildProductsDirectorySuccess = [self.derivedDataDirectory startAccessingSecurityScopedResource];
        if(buildProductsDirectorySuccess == NO) {
            // we have bookmark data but we cannot start accessing it!
          NSAlert *alert = [NSAlert new];
          alert.messageText = @"Failed to access Derived Data Directory";
          [alert addButtonWithTitle:@"Set Directory…"];
          [alert addButtonWithTitle:@"Cancel"];
          alert.informativeText = @"You have set a Xcode derived data directory in the preferences but Core Data Editor failed to access the contents of the directory. If you want to continue to use this feature you should set a new directory now.";
            NSUInteger returnCode = [alert runModal];
            if(returnCode == NSAlertFirstButtonReturn) {
                [self.preferencesWindowController showAutomaticProjectCreationPreferencesWithCompletionHandler:nil];
            }
        }
    }

    return (iPhoneSimulatorSuccess && buildProductsDirectorySuccess);
}

#pragma mark NSApplicationDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification {

    // Start accessing security scoped resources here because this delegate method is called
    // before applicationDidFinishLaunching: and before application:openFile:
    // Since we need access to the resources in both cases...
    [self startAccessingCoreDataEditorSecurityScopedResources];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:@"HELLO" forKey:@"AAAAAAAAAAAAAA"];
    [[NSNotificationCenter defaultCenter] addObserverForName:CDEUserDefaultsNotifications.didChangeSimulatorDirectory object:defaults queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.iPhoneSimulatorDirectory stopAccessingSecurityScopedResource];
        self.iPhoneSimulatorDirectory = defaults.simulatorDirectory_cde;
        [self.iPhoneSimulatorDirectory startAccessingSecurityScopedResource];
        [self.projectBrowserWindowController updateProjectDirectoryURL:self.iPhoneSimulatorDirectory];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:CDEUserDefaultsNotifications.didChangeBuildProductsDirectory object:defaults queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.derivedDataDirectory stopAccessingSecurityScopedResource];
        self.derivedDataDirectory = defaults.buildProductsDirectory_cde;
        [self.derivedDataDirectory startAccessingSecurityScopedResource];
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
    // Create prefs if needed
    if(self.preferencesWindowController == nil) {
        self.preferencesWindowController = [CDEPreferencesWindowController new];
    }
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
    // Need to create prefs?
    if(self.preferencesWindowController == nil) {
        self.preferencesWindowController = [CDEPreferencesWindowController new];
    }
    if([filename.pathExtension isEqualToString:@"coredataeditor5"]) {
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename] display:YES error:NULL];
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
        [self.preferencesWindowController showAutomaticProjectCreationPreferencesAndDisplayInfoSheetWithCompletionHandler:nil];
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
        CDEConfiguration *c = [document createConfiguration];
        error = nil;
        BOOL set = [c setBookmarkDataWithApplicationBundleURL:nil storeURL:storeURL modelURL:modelURL error:&error];
        if(!set) {
            NSLog(@"error: %@", error);
        }
        error = nil;
        BOOL setup = [document setupAndStartAccessingConfigurationRelatedURLsAndGetError:&error];
        if(!setup) {
            NSLog(@"error: %@", error);
        }
        [document makeWindowControllers];
        [document showWindows];
        return YES;
    }
    return NO;
}

@end
