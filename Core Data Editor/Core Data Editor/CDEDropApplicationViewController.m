#import "CDEDropApplicationViewController.h"
#import "CDEDropZoneView.h"
#import "CDEDropZoneViewDelegate.h"

#import "CDEModelChooserItem.h"

#import "CDEDropApplicationViewControllerDelegate.h"
#import "CDEModelChooserSheetController.h"
#import "CDEPathActionLabelController.h"

// Additions: Begin
#import "NSURL+CDEAdditions.h"
#import "NSURL+CDEApplicationAnalyzer.h"
#import "NSPasteboard-CDEAdditions.h"
#import "NSBundle+CDEApplicationAnalyzer.h"
#import "NSBundle+CDEModelFinder.h"
#import "NSError-CDEAdditions.h"
#import "NSWorkspace+CDEAdditions.h"
// Additions: End

typedef NS_ENUM(NSUInteger, CDEManagedObjectModelSourceType) {
    CDEManagedObjectModelSourceTypeSingleModel,
    CDEManagedObjectModelSourceTypeApplicationBundle,
    CDEManagedObjectModelSourceTypeInvalid
};

@interface CDEDropApplicationViewController ()  <CDEDropZoneViewDelegate>

#pragma mark Properties
@property (nonatomic, readwrite, copy) NSURL *modelURL;
@property (nonatomic, readwrite, copy) NSURL *bundleURL;
@property (nonatomic, strong) CDEModelChooserSheetController *modelChooserSheetController;

#pragma mark - Outlets
@property (nonatomic, weak) IBOutlet CDEDropZoneView *dropZoneView;
@property (nonatomic, weak) IBOutlet CDEPathActionLabelController *pathActionLabelController;
@property (nonatomic, weak) IBOutlet NSTextField *infoTextField;

@end

@implementation CDEDropApplicationViewController

#pragma mark Validating Drops
- (CDEManagedObjectModelSourceType)modelSourceTypeForURL:(NSURL *)URL error:(NSError **)error {
    if(URL == nil) {
        return CDEManagedObjectModelSourceTypeInvalid;
    }
    
    if([URL isCompiledManagedObjectModelFile_cde]) {
        return CDEManagedObjectModelSourceTypeSingleModel;
    }
    
    // Test a few common cases:
    NSArray *commonlyUsedIncorrectExtensions = @[@"xcdatamodeld", @"xcdatamodel"];
    if([commonlyUsedIncorrectExtensions containsObject:URL.pathExtension]) {
        if(error != NULL) {
            NSString *description = @"Model format not supported";
            NSString *reason = @"You are dropping a model file which is not compiled. This is not supported. Simply drop your application bundle or a compiled model (.mom, .momd) here instead.";
            *error = [NSError newErrorWithCode:-1 localizedDescription:description localizedRecoverySuggestion_cde:reason];
        }
        return CDEManagedObjectModelSourceTypeInvalid;
    }
    
    NSBundle *bundle = [NSBundle bundleWithURL:URL];
    NSArray *modelChooserItems = [bundle modelChooserItems_cde];
    if(modelChooserItems.count > 0) {
        return CDEManagedObjectModelSourceTypeApplicationBundle;
    }
    return CDEManagedObjectModelSourceTypeInvalid;
}
- (CDEManagedObjectModelSourceType)modelSourceTypeForDraggingInfo:(id<NSDraggingInfo>)drop error:(NSError **)error {
    NSURL *droppedURL = [[drop draggingPasteboard] cde_URL];
    return [self modelSourceTypeForURL:droppedURL error:error];
}

- (NSString *)applicationBundleUTI {
    return @"com.apple.application-bundle";
}

- (BOOL)dropContainsMultipleModels:(id<NSDraggingInfo>)drop {
    NSURL *droppedURL = [[drop draggingPasteboard] cde_URL];
    if(droppedURL == nil) {
        return NO;
    }
    
    NSBundle *bundle = [NSBundle bundleWithURL:droppedURL];
    NSArray *modelChooserItems = [bundle modelChooserItems_cde];
    return (modelChooserItems.count > 1);
}

#pragma mark - Drop Application View Controller
- (void)setModelURL:(NSURL *)newValue {
    if(newValue != _modelURL) {
        _modelURL = [newValue copy];
        [self view];
        [self.pathActionLabelController setPath:self.modelURL.path];
    }
}

- (void)setEditing:(BOOL)newValue {
    _editing = newValue;
    NSString *localizedInfoKey = @"DropApplicationInfoTextWhenCreatingNewProject";
    if(self.isEditing) {
        localizedInfoKey = @"DropApplicationInfoTextWhenEditingProject";
    }
    self.infoTextField.stringValue = NSLocalizedString(localizedInfoKey, nil);
}

- (BOOL)isValid {
    return (self.modelURL != nil && [NSManagedObjectModel canInitWithContentsOfURL:self.modelURL error_cde:NULL]);
}

#pragma mark Configuring Model and Bundle Information
- (void)setModelURL:(NSURL *)newModelURL bundleURL:(NSURL *)newBundleURL {
    [self view];
    self.modelURL = newModelURL;
    self.bundleURL = newBundleURL;
    
    if(self.modelURL != nil) {
        NSError *error = nil;
        BOOL canInitModel = [NSManagedObjectModel canInitWithContentsOfURL:self.modelURL error_cde:&error];
        if(canInitModel == NO) {
            self.dropZoneView.displayedError = error;
        }
    }
    
    self.dropZoneView.URL = self.bundleURL == nil ? self.modelURL : self.bundleURL;
    [self.pathActionLabelController setPath:self.modelURL.path];
    [self.delegate dropModelViewController:self didReceiveModelURL:self.modelURL locatedInApplicationBundleURL:self.bundleURL];
}

#pragma mark Creating
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.delegate = nil;
        self.modelURL = nil;
        self.bundleURL = nil;
        self.editing = NO;
    }
    return self;
}

- (id)init {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

#pragma mark NSViewController
- (void)loadView {
    [super loadView];
    self.infoTextField.stringValue = NSLocalizedString(@"DropApplicationInfoTextWhenCreatingNewProject", nil);
    self.modelChooserSheetController = [CDEModelChooserSheetController new];
    [self.modelChooserSheetController window];
}

#pragma mark CDEDropZoneViewDelegate
- (NSString *)titleForDropZoneView:(CDEDropZoneView *)view {
    return @"Drop Application or Model";
}

- (NSDragOperation)dropZoneView:(CDEDropZoneView *)view validateDrop:(id<NSDraggingInfo>)drop {
    return NSDragOperationEvery;
}

- (BOOL)dropZoneView:(CDEDropZoneView *)view acceptDrop:(id<NSDraggingInfo>)drop {
    return YES;
}

- (void)dropZoneView:(CDEDropZoneView *)view didChangeURL:(NSURL *)URL {
    NSError *error = nil;
    CDEManagedObjectModelSourceType sourceType = [self modelSourceTypeForURL:URL error:&error];
    switch (sourceType) {
        case CDEManagedObjectModelSourceTypeInvalid: {
            NSError *displayedError = error;
            if(error == nil) {
                // create generic error
                displayedError = [NSError newErrorWithCode:-1 localizedDescription:@"This file does not seem to be valid." localizedRecoverySuggestion_cde:@"It does not contain a managed object model."];
            }
            self.dropZoneView.displayedError = displayedError;
            [self setModelURL:nil bundleURL:nil];
            break;
        }
            
        case CDEManagedObjectModelSourceTypeSingleModel: {
            NSError *error = nil;
            BOOL canInitModel = [NSManagedObjectModel canInitWithContentsOfURL:URL error_cde:&error];
            if(canInitModel == NO) {
                self.dropZoneView.displayedError = error;
                [self setModelURL:nil bundleURL:nil];
            } else {
                self.dropZoneView.displayedError = nil;
                [self setModelURL:URL bundleURL:nil];
            }
            
            break;
        }
            
        case CDEManagedObjectModelSourceTypeApplicationBundle: {
            NSBundle *bundle = [NSBundle bundleWithURL:URL];
            [self.modelChooserSheetController setDisplayedModelChooserItems:bundle.modelChooserItems_cde];
            [self.modelChooserSheetController beginSheetModalForWindow:self.view.window completionHandler:^(CDEModelChooserSheetControllerResult result, CDEModelChooserItem *item) {
                if(result == CDEModelChooserSheetControllerResultCancelButton || item == nil) {
                    return;
                }
                [self.dropZoneView setDisplayedError:nil];
                [self setModelURL:item.URL bundleURL:URL];
            }];
            break;
        }
            
        default: {
            NSLog(@"Encountered invalid model source type.");
            break;
        }
    }
}

@end
