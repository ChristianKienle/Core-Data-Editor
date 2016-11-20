#import "CDEDocument.h"
#import "CDEConfigurationWizzard.h"
#import "CDEConfiguration.h"
#import "CDEEditorViewController.h"

// Additions: Begin
#import "NSURL+CDEAdditions.h"
#import "NSWorkspace+CDEAdditions.h"
// Additions: End

#import "CDEManagedObjectIDToStringValueTransformer.h"
#import "CDEAutosaveInformation.h"

@interface CDEDocument ()

#pragma mark - Properties
@property (strong) CDEConfiguration *configuration;
@property (strong) CDEConfigurationWizzard *configurationWizzard;
@property (strong) CDEEditorViewController *editorViewController;
@property (weak) IBOutlet NSView *containerView;

@property (readonly) NSURL *storeURL;
@property (readonly) NSURL *modelURL;
@property (readonly) NSURL *applicationBundleURL;

#pragma mark - Actions
- (IBAction)showConfiguration:(id)sender;

@end

@implementation CDEDocument

#pragma mark - NSObject
+ (void)initialize {
  if(self == [CDEDocument class]) {
    [CDEManagedObjectIDToStringValueTransformer registerDefaultManagedObjectIDToStringValueTransformer];
  }
}

- (NSURL *)storeURL { return self.configuration.storeURL; }

- (NSURL *)modelURL { return self.configuration.modelURL; }
- (NSURL *)applicationBundleURL { return self.configuration.applicationBundleURL; }

- (NSWindow*)_documentWindow {
  NSParameterAssert(self.windowControllers.count == 1);
  
  if([[self windowControllers] count] == 1) {
    return [[self windowControllers][0] window];
  }
  return nil;
}

#pragma mark - Actions
- (IBAction)showConfiguration:(id)sender {
  [self.configurationWizzard window];
  __typeof__(self) __weak weakSelf = self;
  [self.configurationWizzard beginSheetModalForWindow:[self _documentWindow]
                                 applicationBundleURL:self.applicationBundleURL
                                             storeURL:self.storeURL
                                             modelURL:self.modelURL completionHandler:^(BOOL success, NSURL *applicationBundleURL, NSURL *storeURL, NSURL *modelURL) {
                                               if(success == NO) {
                                                 return;
                                               }
                                               
                                               [self.configuration setApplicationBundleURL:applicationBundleURL storeURL:storeURL modelURL:modelURL];
                                               
                                               [weakSelf.editorViewController setConfiguration:self.configuration modelURL:self.modelURL storeURL:self.storeURL needsReload:YES error:NULL];
                                             }];
}

- (IBAction)refresh:(id)sender {
  [self.editorViewController setConfiguration:self.configuration modelURL:self.modelURL storeURL:self.storeURL needsReload:YES error:NULL];
}


#pragma mark - NSDocument
- (instancetype)init {
  self = [super init];
  if (self) {
    self.configurationWizzard = [CDEConfigurationWizzard new];
    self.editorViewController = [CDEEditorViewController new];
  }
  return self;
}

- (NSString *)windowNibName {
  return @"CDEDocument";
}

+ (BOOL)preservesVersions {
  return NO;
}

- (void)dealloc {
  self.editorViewController = nil;
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
  // Validate the Entity menu
  if([item action] == @selector(deleteSelectedObjcts:)) {
    return self.editorViewController.canDeleteSelectedManagedObjects;
  }
  if([item action] == @selector(insertObject:)) {
    return self.editorViewController.canInsertManagedObject;
  }
  if([item action] == @selector(copySelectedObjectsAsCSV:)) {
    return self.editorViewController.canCreateCSVRepresentationWithSelectedObjects;
  }
  
  // Let super do its work
  return [super validateUserInterfaceItem:item];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)item {
  if([item.itemIdentifier isEqualToString:@"CDECode"]) {
    return (self.configuration.storePath != nil && self.configuration.modelPath != nil);
  }
  if([item.itemIdentifier isEqualToString:@"CDECSV"]) {
    return (self.configuration.storePath != nil && self.configuration.modelPath != nil);
  }
  return YES;
}

-(BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
  CDEConfiguration *c = [[CDEConfiguration alloc] initWithData: data];
  self.configuration = c;
  return YES;
}

-(NSData *)dataOfType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
  NSError *saveError = nil;
  [self.editorViewController save:&saveError];
  if(saveError != nil) {
    [NSApp presentError:saveError];
  }
  
  return self.configuration.data;
}

- (CDEConfiguration *)createConfiguration {
  CDEConfiguration *configuration = [CDEConfiguration new];
  self.configuration =  configuration;
  
  [self updateChangeCount:NSChangeCleared];
  return configuration;
}

- (void)_createConfiguration {
  CDEConfiguration *configuration = [CDEConfiguration new];
  self.configuration =  configuration;
  
  [self updateChangeCount:NSChangeCleared];
}

- (void)createConfigurationAndShowWizzard {
  [self _createConfiguration];
  __typeof__(self) __weak weakSelf = self;
  [self.configurationWizzard beginSheetModalForWindow:[self _documentWindow] completionHandler:^(BOOL success, NSURL *applicationBundleURL, NSURL *storeURL, NSURL *modelURL) {
    if(success == NO) {
      return;
    }
    
    [self.configuration setApplicationBundleURL:applicationBundleURL storeURL:storeURL modelURL:modelURL];
    [weakSelf.editorViewController setConfiguration:self.configuration modelURL:self.modelURL storeURL:self.storeURL needsReload:YES error:NULL];
  }];
  
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
  [super windowControllerDidLoadNib:windowController];
  
  [self _documentWindow].titleVisibility = NSWindowTitleHidden;
  self.editorViewController.view.frame = self.containerView.bounds;
  [self.containerView addSubview:self.editorViewController.view];
  
  if(self.configuration == nil) {
    [self createConfigurationAndShowWizzard];
  }
  else {
    // - store and model incompatible
    // - model invalid
    NSMutableOrderedSet *errorMessages = [NSMutableOrderedSet orderedSet];
    NSFileManager *fs = [NSFileManager defaultManager];
    if([fs fileExistsAtPath:self.modelURL.path] == NO) {
      [errorMessages addObject:@"• Model could not be found."];

    }
    if([fs fileExistsAtPath:self.storeURL.path] == NO) {
      [errorMessages addObject:@"• Store could not be found."];
    }
    
    // If there aren't any error messages we can check for compatibility
    NSManagedObjectModel *model = nil;
    @try {
      model = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
      if(model == nil) {
        [errorMessages addObject:@"• Model could not be loaded."];
      }
    }
    @catch (NSException *exception) {
      [errorMessages addObject:@"• Model could not be loaded because an exception occured."];
      NSString *exceptionMessage = [NSString stringWithFormat:@"%@\nReason: %@\nUser Info: %@", [exception name], [exception reason], [exception userInfo]];
      NSLog(@"Exception raised:\n%@", exceptionMessage);
      NSLog(@"Backtrace: %@", [exception callStackSymbols]);
    }
    if(model != nil) {
      NSError *error = nil;
      BOOL configurationSet = [self.editorViewController setConfiguration:self.configuration modelURL:self.modelURL storeURL:self.storeURL needsReload:YES error:&error];
      if(configurationSet == NO) {
        [errorMessages addObject:@"• Configuration is invalid."];
      }
    }
    
    BOOL configurationIsValid = (errorMessages.count == 0);
    if(!configurationIsValid) {
      NSString *message = nil;
      if(errorMessages.count > 1) {
        message = @"There were multiple problems with the current project configuration:\n\n";
      } else {
        message = @"There is one problem with the current project configuration:\n\n";
      }
      NSString *errorMessagesForDisplay = [errorMessages.array componentsJoinedByString:@"\n"];
      message = [message stringByAppendingString:errorMessagesForDisplay];
      message = [message stringByAppendingString:@"\n\nYou can configure the project now to resolve those problems. If you do so the project will be usable again."];
      
      NSAlert *alert = [NSAlert new];
      alert.messageText = message;
      alert.informativeText = @"Unable to open Project";
      [alert addButtonWithTitle:@"Configure"];
      [alert addButtonWithTitle:@"Cancel"];
      [alert beginSheetModalForWindow:[self _documentWindow] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn) { // "Configure" was clicked
          [self.configurationWizzard setEditing:YES];
          double delayInSeconds = 0.5;
          dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
          dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showConfiguration:self];
          });
        } else { // "Cancel" was clicked
          [self close];
        }
        
      }];
    }
  }
}

- (void)close {
  [self.editorViewController cleanup];
  [super close];
}

+ (BOOL)autosavesInPlace {
  return YES;
}

#pragma mark - Query Control
- (IBAction)takeQueryFromSender:(id)sender {
  [self.editorViewController takeQueryFromSender:sender];
}

#pragma mark - Actions
- (IBAction)deleteSelectedObjcts:(id)sender {
  [self.editorViewController deleteSelectedObjcts:sender];
}

- (IBAction)insertObject:(id)sender {
  [self.editorViewController insertObject:sender];
}

- (IBAction)copySelectedObjectsAsCSV:(id)sender {
  [self.editorViewController copySelectedObjectsAsCSV:sender];
}

#pragma mark - Importing/Exporting
- (IBAction)showImportCSVFileWindow:(id)sender {
  [self.editorViewController showImportCSVFileWindow:sender];
}

@end
