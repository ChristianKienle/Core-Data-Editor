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
#import "CDECodeGenerator.h"

@interface CDEDocument ()

#pragma mark - Properties
@property (nonatomic, strong) CDEConfiguration *configuration;
@property (nonatomic, strong) CDEConfigurationWizzard *configurationWizzard;
@property (nonatomic, strong) CDEEditorViewController *editorViewController;
@property (nonatomic, weak) IBOutlet NSView *containerView;

@property (nonatomic, copy) NSURL *storeURL;
@property (nonatomic, copy) NSURL *modelURL;
@property (nonatomic, copy) NSURL *applicationBundleURL;

#pragma mark - Actions
- (IBAction)showConfiguration:(id)sender;

#pragma mark - Code Generation
@property (nonatomic, strong) CDECodeGenerator *codeGenerator;

@end

@implementation CDEDocument

#pragma mark - NSObject
+ (void)initialize {
    if(self == [CDEDocument class]) {
        [CDEManagedObjectIDToStringValueTransformer registerDefaultManagedObjectIDToStringValueTransformer];
    }
}

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
                                                   
        NSError *error = nil;
        BOOL bookmarkDataSet = [self.configuration setBookmarkDataWithApplicationBundleURL:applicationBundleURL storeURL:storeURL modelURL:modelURL error:&error];
        if(bookmarkDataSet == NO) {
            [NSApp presentError:error];
            return;
        }
        
        // Resolve
        NSError *resolveError = nil;
        BOOL resolved = [self setupAndStartAccessingConfigurationRelatedURLsAndGetError:&resolveError];
        if(resolved == NO) {
            [NSApp presentError:resolveError];
            return;
        }
        
        [weakSelf.editorViewController setConfiguration:self.configuration modelURL:self.modelURL storeURL:self.storeURL needsReload:YES error:NULL];
    }];
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
        return (self.configuration.storeBookmarkData != nil && self.configuration.modelBookmarkData != nil);
    }
    if([item.itemIdentifier isEqualToString:@"CDECSV"]) {
        return (self.configuration.storeBookmarkData != nil && self.configuration.modelBookmarkData != nil);
    }
    return YES;
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError **)error {
    NSError *saveError = nil;
    [self.editorViewController save:&saveError];
    BOOL result = [super writeToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation originalContentsURL:absoluteOriginalContentsURL error:error];
    if(saveError != nil) {
        [NSApp presentError:saveError];
    }
    return result;
}

- (CDEConfiguration *)createConfiguration {
    [[[self managedObjectContext] undoManager] disableUndoRegistration];
    CDEConfiguration *configuration = [CDEConfiguration insertInManagedObjectContext:self.managedObjectContext];
    self.configuration =  configuration;
    
    [[[self managedObjectContext] undoManager] enableUndoRegistration];
    [[self managedObjectContext] processPendingChanges];
    [[[self managedObjectContext] undoManager] removeAllActions];
    [self updateChangeCount:NSChangeCleared];
    return configuration;
}

- (void)_createConfiguration {
    [[[self managedObjectContext] undoManager] disableUndoRegistration];
    CDEConfiguration *configuration = [CDEConfiguration insertInManagedObjectContext:self.managedObjectContext];
    self.configuration =  configuration;
    
    [[[self managedObjectContext] undoManager] enableUndoRegistration];
    [[self managedObjectContext] processPendingChanges];
    [[[self managedObjectContext] undoManager] removeAllActions];
    [self updateChangeCount:NSChangeCleared];
}

- (void)createConfigurationAndShowWizzard {
    [self _createConfiguration];
    __typeof__(self) __weak weakSelf = self;
    [self.configurationWizzard beginSheetModalForWindow:[self _documentWindow] completionHandler:^(BOOL success, NSURL *applicationBundleURL, NSURL *storeURL, NSURL *modelURL) {
        if(success == NO) {
            return;
        }
        
        NSError *error = nil;
        BOOL bookmarkDataSet = [self.configuration setBookmarkDataWithApplicationBundleURL:applicationBundleURL storeURL:storeURL modelURL:modelURL error:&error];
        if(bookmarkDataSet == NO) {
            [NSApp presentError:error];
            return;
        }
        
        // Resolve
        NSError *resolveError = nil;
        BOOL resolved = [self setupAndStartAccessingConfigurationRelatedURLsAndGetError:&resolveError];
        if(resolved == NO) {
            [NSApp presentError:resolveError];
            return;
        }

        [weakSelf.editorViewController setConfiguration:self.configuration modelURL:self.modelURL storeURL:self.storeURL needsReload:YES error:NULL];
    }];

}

- (BOOL)setupAndStartAccessingConfigurationRelatedURLsAndGetError:(NSError **)error {
    NSParameterAssert(self.configuration);
    
    NSError *resolveError = nil;
    self.modelURL = [NSURL URLByResolvingBookmarkData:self.configuration.modelBookmarkData
                                            error_cde:&resolveError];
    
    if(self.modelURL == nil) {
        NSLog(@"Error resolving model URL: %@", resolveError);
        if(error != NULL) {
            *error = resolveError;
        }
        
        return NO;
    }
    if([self.modelURL startAccessingSecurityScopedResource] == NO) {
        NSLog(@"Error accessing model URL (%@).", self.modelURL);
        
        return NO;
    }
    
    resolveError = nil;
    self.storeURL = [NSURL URLByResolvingBookmarkData:self.configuration.storeBookmarkData
                                            error_cde:&resolveError];
    if(self.storeURL == nil) {
        NSLog(@"Error resolving store URL: %@", resolveError);
        if(error != NULL) {
            *error = resolveError;
        }
        return NO;
    }
    
    if([self.storeURL startAccessingSecurityScopedResource] == NO) {
        NSLog(@"Error accessing store URL (%@).", self.storeURL);
        return NO;
    }
    
    return YES;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
  
  [self _documentWindow].titleVisibility = NSWindowTitleHidden;
    self.editorViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.editorViewController.view];
    
    self.configuration = [CDEConfiguration fetchedConfigurationInManagedObjectContext:self.managedObjectContext error:NULL];
    
    if(self.configuration == nil) {
        [self createConfigurationAndShowWizzard];
    }
    else {
        // Resolve
        // Possible errors:
        // - modelURL:
        //     A: could not be resolved: file does not exist (NSCocoaErrorDomain, Code: NSFileNoSuchFileError)
        //     B: could not be resolved: other error
        //     C: start accessing failed
        // - storeURL could not be resolved:
        //     A: could not be resolved: file does not exist (NSCocoaErrorDomain, Code: NSFileNoSuchFileError)
        //     B: could not be resolved: other error
        //     C: start accessing failed
        // - store and model incompatible
        // - model invalid
        NSMutableOrderedSet *errorMessages = [NSMutableOrderedSet orderedSet];
        NSError *resolveError = nil;
        self.modelURL = [NSURL URLByResolvingBookmarkData:self.configuration.modelBookmarkData options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:&resolveError];
        if(self.modelURL == nil) {
            if([[resolveError domain] isEqualToString:NSCocoaErrorDomain] && resolveError.code == NSFileNoSuchFileError) {
                [errorMessages addObject:@"• Model could not be found."];
            } else {
                [errorMessages addObject:[@"• " stringByAppendingString:resolveError.localizedDescription]];
            }
            NSLog(@"error: %@", resolveError);
        } else {
            if([self.modelURL startAccessingSecurityScopedResource] == NO) {
                NSLog(@"failed to access model");
                [errorMessages addObject:@"• Model could not be accessed."];
            }
        }
        
        resolveError = nil;
        self.storeURL = [NSURL URLByResolvingBookmarkData:self.configuration.storeBookmarkData options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:&resolveError];
        if(self.storeURL == nil) {
            if([[resolveError domain] isEqualToString:NSCocoaErrorDomain] && resolveError.code == NSFileNoSuchFileError) {
                [errorMessages addObject:@"• Store could not be found."];
            } else {
                [errorMessages addObject:[@"• " stringByAppendingString:resolveError.localizedDescription]];
            }

            NSLog(@"error: %@", resolveError);
        } else {
            if([self.storeURL startAccessingSecurityScopedResource] == NO) {
                [errorMessages addObject:@"• Store could not be accessed."];
                NSLog(@"failed to access store");
            }
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

- (IBAction)generateCode:(id)sender {
    if(self.codeGenerator != nil) {
        self.codeGenerator = nil;
    }
    
    self.codeGenerator = [[CDECodeGenerator alloc] initWithManagedObjectModelURL:self.modelURL];
    __typeof__(self) __weak weakSelf = self;
    [self.codeGenerator presentCodeGeneratorUIModalForWindow:[self _documentWindow] completionHandler:^{
        [weakSelf setCodeGenerator:nil];
    }];
}


@end
