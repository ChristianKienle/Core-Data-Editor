#import "CDEConfigurationWizzard.h"
#import "CDEDropZoneView.h"
#import "CDEDropApplicationViewController.h"
#import "CDEDropStoreViewController.h"
#import "CDENewConfigurationSummaryViewController.h"
#import "CDEConfigurationSummaryRequest.h"
#import "CDEModelChooserItem.h"

#import "CDEDropApplicationViewControllerDelegate.h"
#import "CDEDropStoreViewControllerDelegate.h"


// Additions: Begin
#import "NSPasteboard-CDEAdditions.h"
#import "NSBundle+CDEModelFinder.h"
#import "NSWorkspace+CDEAdditions.h"
// Additions: End

@interface CDEConfigurationWizzard () <CDEDropModelViewControllerDelegate, CDEDropStoreViewControllerDelegate>

#pragma mark - Outlets
@property (nonatomic, weak) IBOutlet NSButton *nextAndCreateButton;
@property (nonatomic, weak) IBOutlet NSView *containerView;
@property (nonatomic, weak) IBOutlet NSTextField *titleTextField;
@property (nonatomic, weak) IBOutlet NSImageView *backgroundImageView;

#pragma mark Private Properties
@property (nonatomic, copy) CDEConfigurationWizzardCompletionHandler beginSheetCompletionHandler;
@property (nonatomic, strong) CDEDropApplicationViewController *dropApplicationViewController;
@property (nonatomic, strong) CDEDropStoreViewController *dropStoreViewController;
@property (nonatomic, strong) CDENewConfigurationSummaryViewController *summaryViewController;

#pragma mark Actions
- (IBAction)dismiss:(id)sender;
- (IBAction)nextShowSummaryCreate:(id)sender;

@end

@interface CDEConfigurationWizzard (Private)

#pragma mark Working with the nextAndDone Button
- (void)updateNextAndDoneButton;

#pragma mark Working with the Subviewcontroller
- (BOOL)displaysDropApplicationView;
- (BOOL)displaysDropStoreView;
- (BOOL)displaysSummaryView;
- (void)showDropApplicationView;
- (void)showDropStoreView;
- (void)showSummaryView;
- (void)showViewInContainerView:(NSView *)viewToShow;

#pragma mark Validating Drops
- (NSString *)applicationBundleUTI;
- (BOOL)dropIsValidApplication:(id<NSDraggingInfo>)drop;

@end

@implementation CDEConfigurationWizzard (Private)

#pragma mark Working with the nextAndDone Button
- (void)updateNextAndDoneButton {
    NSString *newTitle = @"Next";
    BOOL enabled = NO;
    
    if([self displaysDropApplicationView]) {
        enabled = (self.dropApplicationViewController.isValid);
    }
    if([self displaysDropStoreView]) {
        newTitle = @"Next";
        enabled = (self.dropStoreViewController.validStoreURL != nil);
    }
    
    if([self displaysSummaryView]) {
        newTitle = @"Create";
        if(self.isEditing == YES) {
            newTitle = @"Save";
        }
        enabled = YES;
    }
    [self.nextAndCreateButton setEnabled:enabled];
    [self.nextAndCreateButton setTitle:newTitle];
}

#pragma mark Working with the Subviewcontroller
- (BOOL)displaysDropApplicationView {
    return (self.dropApplicationViewController.view.superview != nil);
}

- (BOOL)displaysDropStoreView {
    return (self.dropStoreViewController.view.superview != nil);
}

- (BOOL)displaysSummaryView {
    return (self.summaryViewController.view.superview != nil);
}

- (void)showDropApplicationView {
    [self showViewInContainerView:self.dropApplicationViewController.view];
}

- (void)showDropStoreView {
    [self showViewInContainerView:self.dropStoreViewController.view];
}

- (void)showSummaryView {
    [self showViewInContainerView:self.summaryViewController.view];
}

- (void)showViewInContainerView:(NSView *)viewToShow {
    if(self.dropApplicationViewController.view.superview != nil) {
        [self.dropApplicationViewController.view removeFromSuperview];
    }
    if(self.summaryViewController.view.superview != nil) {
        [self.summaryViewController.view removeFromSuperview];
    }
    if(self.dropStoreViewController.view.superview != nil) {
        [self.dropStoreViewController.view removeFromSuperview];
    }
//    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    viewToShow.frame = self.containerView.bounds;
    [self.containerView addSubview:viewToShow];
    [self updateNextAndDoneButton];
}

#pragma mark Validating Drops
- (NSString *)applicationBundleUTI {
    return @"com.apple.application-bundle";
}

- (BOOL)dropIsValidApplication:(id<NSDraggingInfo>)drop {
    NSURL *droppedURL = [[drop draggingPasteboard] cde_URL];
    if(droppedURL == nil) {
        return NO;
    }
    NSString *UTI = [[NSWorkspace sharedWorkspace] typeOfFile:droppedURL.path error:nil];
    return [[NSWorkspace sharedWorkspace] type:UTI conformsToType:[self applicationBundleUTI]];
}

@end

@implementation CDEConfigurationWizzard

#pragma mark Properties
- (void)setEditing:(BOOL)newValue {
    _editing = newValue;
    NSString *localizedInfoKey = @"ConfigurationWizzardTitleWhenCreatingNewProject";
    if(self.isEditing) {
        localizedInfoKey = @"ConfigurationWizzardTitleWhenEditingProject";
    }
    self.titleTextField.stringValue = NSLocalizedString(localizedInfoKey, nil);
    self.dropApplicationViewController.editing = self.isEditing;
    self.dropStoreViewController.editing = self.isEditing;
    self.backgroundImageView.alphaValue = 0.05;
}

#pragma mark Creating
- (instancetype)init {
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if(self) {
        self.beginSheetCompletionHandler = nil;
        self.editing = NO;
    }
    return self;
}

#pragma mark NSWindowController
- (void)windowDidLoad {
    [super windowDidLoad];
    self.dropApplicationViewController = [CDEDropApplicationViewController new];
    self.dropApplicationViewController.delegate = self;
    self.dropApplicationViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.dropApplicationViewController.view];
    
    self.dropStoreViewController = [CDEDropStoreViewController new];
    self.dropStoreViewController.delegate = self;
    self.summaryViewController = [CDENewConfigurationSummaryViewController new];
    self.backgroundImageView.alphaValue = 0.05;
    self.editing = NO;
}

#pragma mark Running the Wizzard
- (void)beginSheetModalForWindow:(NSWindow *)parentWindow completionHandler:(CDEConfigurationWizzardCompletionHandler)handler {
    self.beginSheetCompletionHandler = handler;
    [self.dropApplicationViewController view];
    [self.dropStoreViewController view];
    [self.summaryViewController view];
    [self showDropApplicationView];
    self.editing = NO;
    
    [NSApp beginSheet:self.window modalForWindow:parentWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (void)beginSheetModalForWindow:(NSWindow *)parentWindow applicationBundleURL:(NSURL *)applicationBundleURL storeURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL completionHandler:(CDEConfigurationWizzardCompletionHandler)handler {
    self.beginSheetCompletionHandler = handler;
    [self.dropApplicationViewController view];
    [self.dropStoreViewController view];
    [self.summaryViewController view];
    [self.dropStoreViewController setValidStoreURL:storeURL];
    [self.dropApplicationViewController setModelURL:modelURL bundleURL:applicationBundleURL];
    [self showDropApplicationView];
    
    self.editing = YES;
    
    [NSApp beginSheet:self.window modalForWindow:parentWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

#pragma mark Actions
- (IBAction)dismiss:(id)sender {
    [NSApp endSheet:self.window];
    [self.window orderOut:sender];
    (self.beginSheetCompletionHandler)(NO, nil, nil, nil);
    self.beginSheetCompletionHandler = nil;
}

- (IBAction)nextShowSummaryCreate:(id)sender {
    if([self displaysDropApplicationView]) {
        // Show the store drop zone view
        [self.dropApplicationViewController.view removeFromSuperview];
        self.dropStoreViewController.view.frame = self.containerView.bounds;
        [self.containerView addSubview:self.dropStoreViewController.view];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.dropApplicationViewController.modelURL];
        model = model.transformedManagedObjectModel_cde;
        self.dropStoreViewController.managedObjectModel = model;
        [self updateNextAndDoneButton];
        return;
    }
    
    if([self displaysDropStoreView]) {
        // Show the summary view
        [self.dropStoreViewController.view removeFromSuperview];
        self.summaryViewController.view.frame = self.containerView.bounds;
        [self.containerView addSubview:self.summaryViewController.view];
        
        CDEConfigurationSummaryRequest *summaryRequest = [[CDEConfigurationSummaryRequest alloc] initWithApplicationBundleURL:self.dropApplicationViewController.bundleURL storeURL:self.dropStoreViewController.validStoreURL];
        self.summaryViewController.representedObject = summaryRequest;
        
        [self updateNextAndDoneButton];
        return;
    }
    
    if([self displaysSummaryView]) {
        // Create
        [NSApp endSheet:self.window];
        [self.window orderOut:sender];
        NSURL *modelURL = self.dropApplicationViewController.modelURL;
        NSURL *applicationBundleURL = self.dropApplicationViewController.bundleURL;
        if(modelURL == nil && applicationBundleURL != nil) {
            NSBundle *bundle = [NSBundle bundleWithURL:applicationBundleURL];
            
            NSArray *modelItems = [bundle modelChooserItems_cde];
            if(modelItems != nil && modelItems.count > 0) {
                modelURL = [[modelItems lastObject] URL];
            }
        }
        (self.beginSheetCompletionHandler)(YES, applicationBundleURL, self.dropStoreViewController.validStoreURL, modelURL);
        return;
    }
}

#pragma mark Actions
- (IBAction)watchTutorial:(id)sender {
    [[NSWorkspace sharedWorkspace] openCreateProjectTutorial_cde];
}

#pragma mark CDEDropApplicationViewControllerDelegate
// When modelURL is not nil it is a URL to a valid model
- (void)dropModelViewController:(CDEDropApplicationViewController *)controller didReceiveModelURL:(NSURL *)modelURL locatedInApplicationBundleURL:(NSURL *)applicationBundleURL {
    if(modelURL == nil) {
        self.dropStoreViewController.managedObjectModel = nil;
        [self updateNextAndDoneButton];
        return;
    }
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.dropStoreViewController.managedObjectModel = managedObjectModel.transformedManagedObjectModel_cde;
    [self updateNextAndDoneButton];
}

#pragma mark CDEDropStoreViewControllerDelegate
- (void)dropStoreViewController:(CDEDropStoreViewController *)controller didChangeStoreURL:(NSURL *)storeURL {
    [self updateNextAndDoneButton];
}

@end
