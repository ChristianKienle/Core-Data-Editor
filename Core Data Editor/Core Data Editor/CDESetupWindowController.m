#import "CDESetupWindowController.h"
#import "CDEPathPickerPopUpButton.h"
#import "NSURL+CDEAdditions.h"
#import "CDEApplicationDelegate.h"

@interface CDESetupWindowController ()

@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, weak) IBOutlet CDEPathPickerPopUpButton *simulatorPathPopupButton;
@property (nonatomic, weak) IBOutlet CDEPathPickerPopUpButton *derivedDataPathPopupButton;

@end

@implementation CDESetupWindowController

- (instancetype)init {
    self = [super initWithWindowNibName:@"CDESetupWindowController" owner:self];
    if(self) {
    
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.simulatorPathPopupButton.otherItemSelectedHandler = ^(CDEPathPickerPopUpButton *sender) {
        [self showSimulatorDirectoryPicker:sender];
    };
    self.derivedDataPathPopupButton.otherItemSelectedHandler = ^(CDEPathPickerPopUpButton *sender) {
        [self showDerivdedDataPicker:sender];
    };
}


- (IBAction)showSimulatorDirectoryPicker:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setShowsHiddenFiles:YES];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            defaults.simulatorDirectory_cde = panel.URL;
            self.simulatorPathPopupButton.URL = defaults.simulatorDirectory_cde;
        }
    }];
}

- (IBAction)showDerivdedDataPicker:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            defaults.buildProductsDirectory_cde = panel.URL;
            self.derivedDataPathPopupButton.URL = defaults.buildProductsDirectory_cde;
        }
    }];
}


#pragma mark - Actions
- (IBAction)beginSetupProcess:(id)sender {
    [self.tabView selectNextTabViewItem:sender];
}

- (IBAction)showBuildProductsSetupTab:(id)sender {
    [self.tabView selectNextTabViewItem:sender];
}

- (IBAction)showSummary:(id)sender {
    [self.tabView selectNextTabViewItem:sender];
    [[NSUserDefaults standardUserDefaults] setApplicationNeedsSetup_cde:NO];
}

- (IBAction)openProjectBrowser:(id)sender {
    [self.window orderOut:self];
    [(CDEApplicationDelegate *)[NSApp delegate] showProjectBrowser:sender];
}

- (IBAction)createNewProject:(id)sender {
    [self.window orderOut:self];
    [[NSDocumentController sharedDocumentController] newDocument:self];
}

@end
