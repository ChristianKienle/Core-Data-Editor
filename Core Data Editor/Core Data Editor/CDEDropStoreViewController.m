#import "CDEDropStoreViewController.h"
#import "CDEDropZoneView.h"
#import "CDEDropStoreViewControllerDelegate.h"
#import "CDEPathActionLabelController.h"

// Additions: Begin
#import "NSPersistentStore+CDEStoreAnalyzer.h"
// Additions: End


@implementation CDEDropStoreViewController (Private)

- (BOOL)isValidStoreAtURL:(NSURL *)URL error:(NSError **)error {
    NSAssert(self.managedObjectModel != nil, @"We need a managed object model.");
    
    if(URL == nil) {
        NSLog(@"Drop has no URL.");
        return NO;
    }
    BOOL result = [self.managedObjectModel isCompatibleWithStoreAtURL:URL error_cde:error];

    return result;
}

- (BOOL)dropIsValidStore:(id<NSDraggingInfo>)drop error:(NSError **)error {
    NSAssert(self.managedObjectModel != nil, @"We need a managed object model.");
    
    NSPasteboard *pasteboard = [drop draggingPasteboard];
    NSURL *URL = [NSURL URLFromPasteboard:pasteboard];
    return [self isValidStoreAtURL:URL error:error];
}

@end

@implementation CDEDropStoreViewController

- (void)setValidStoreURL:(NSURL *)newValue {
   if(newValue != _validStoreURL) {
      _validStoreURL = [newValue copy];
      [self view];
      [self.pathActionLabelController setPath:self.validStoreURL.path];
      [self.dropZoneView setURL:self.validStoreURL];
   }
}

- (void)setEditing:(BOOL)newValue {
   _editing = newValue;
   [self view];
   NSString *localizedInfoKey = @"DropStoreInfoTextWhenCreatingNewProject";
   if(self.isEditing) {
      localizedInfoKey = @"DropStoreInfoTextWhenEditingProject";
   }
   self.infoTextField.stringValue = NSLocalizedString(localizedInfoKey, nil);
}

#pragma mark Creating
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

   if(self) {
      self.validStoreURL = nil;
      self.delegate = nil;
      self.managedObjectModel = nil;
      self.editing = NO;
   }
   return self;
}

- (id)init {
   return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

#pragma mark Actions
- (IBAction)createNewStore:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if(result != NSFileHandlingPanelOKButton) {
            return;
        }
        NSURL *URL = [panel URL];

        NSURL *temp = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:[[NSUUID UUID] UUIDString] isDirectory:YES];
        NSFileManager *fileManager = [NSFileManager new];
        NSError *error = nil;
        if([fileManager createDirectoryAtURL:temp withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            NSLog(@"Failed to create new store: %@", error);
            [[NSDocumentController sharedDocumentController] presentError:error];
            return;
        }
        temp = [temp URLByAppendingPathComponent:[URL lastPathComponent] isDirectory:NO];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        error = nil;
        NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:temp options:nil error:&error];
        if(store == nil) {
            [[NSDocumentController sharedDocumentController] presentError:error];
            return;
        }
        error = nil;
        NSData *storeData = [NSData dataWithContentsOfURL:temp options:0 error:&error];
        if(storeData == nil) {
            NSLog(@"Failed to create new store (read failed): %@", error);
            [[NSDocumentController sharedDocumentController] presentError:error];
            return;
        }
        [storeData writeToURL:URL atomically:YES];
        [self setValidStoreURL:URL];
        [self.delegate dropStoreViewController:self didChangeStoreURL:self.validStoreURL];
    }];
}

#pragma mark CDEDropZoneViewDelegate
- (NSString *)titleForDropZoneView:(CDEDropZoneView *)view {
   return @"Drop your Persistent Store here.\n\nIf you don't have one click on \"Create Store File\".";
}

- (NSDragOperation)dropZoneView:(CDEDropZoneView *)view validateDrop:(id<NSDraggingInfo>)info {
    NSError *error = nil;
    BOOL isValid = [self dropIsValidStore:info error:&error];
    if(isValid == NO) {
        self.dropZoneView.displayedError = error;
        return NSDragOperationNone;
    }
    return NSDragOperationEvery;
}

- (BOOL)dropZoneView:(CDEDropZoneView *)view acceptDrop:(id<NSDraggingInfo>)info {
    NSError *error = nil;
    BOOL isValid = [self dropIsValidStore:info error:&error];
    if(isValid == NO) {
        self.dropZoneView.displayedError = error;
        return NO;
    }
    return YES;
}

- (void)dropZoneView:(CDEDropZoneView *)view didChangeURL:(NSURL *)newURL {
    NSError *error = nil;
    BOOL validStore = [self isValidStoreAtURL:newURL error:&error];
    if(validStore) {
        self.validStoreURL = newURL;
        self.dropZoneView.displayedError = nil;
        [self.delegate dropStoreViewController:self didChangeStoreURL:newURL];
    } else {
        self.dropZoneView.displayedError = error;
        self.validStoreURL = nil;
    }
}

@end
