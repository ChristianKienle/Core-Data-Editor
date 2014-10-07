#import "CDEPreferencesAutomaticProjectCreationViewController.h"
#import "NSURL+CDEAdditions.h"
#import "CDEPathPickerPopUpButton.h"

@interface CDEPreferencesAutomaticProjectCreationViewController ()

#pragma mark - Properties
@property (nonatomic, weak) IBOutlet CDEPathPickerPopUpButton *buildDirectoryPopUpButton;
@property (nonatomic, weak) IBOutlet CDEPathPickerPopUpButton *simulatorDirectoryPopUpButton;

@end

@implementation CDEPreferencesAutomaticProjectCreationViewController

- (void)loadView {
    [super loadView];
    self.buildDirectoryPopUpButton.otherItemSelectedHandler = ^(CDEPathPickerPopUpButton *sender) {
        [self showBuildDirectoryPicker:sender];
    };
    self.simulatorDirectoryPopUpButton.otherItemSelectedHandler = ^(CDEPathPickerPopUpButton *sender) {
        [self showSimulatorDirectoryPicker:sender];
    };
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.simulatorDirectoryPopUpButton.URL = defaults.simulatorDirectory_cde;
    self.buildDirectoryPopUpButton.URL = defaults.buildProductsDirectory_cde;
}

- (void)displayInfoSheet {
  NSAlert *alert = [NSAlert new];
  alert.messageText = @"Automatic Project Creation";
  alert.informativeText = @"In order to open a store file Core Data Editor needs to know the model which belongs to the store file. Core Data Editor can try to find the model for you automatically. Simply specify a directory which contains most of your build products in the preferences. This is usually the Xcode derived data directory (Default: ~/Library/Developer/Xcode/DerivedData).\n\nIf you have selected your Xcode derived data directory try to drop a store file from your app on the dock icon of Core Data Editor.";
  [alert addButtonWithTitle:@"Configure Derived Data Directory"];
  [alert addButtonWithTitle:@"Cancel"];
  
  [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
    if(returnCode != NSAlertFirstButtonReturn) {
      double delayInSeconds = 0.5;
      dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
      dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.view.window performClose:self];
      });
    }
  }];
}

#pragma mark - Directories
- (IBAction)showSimulatorDirectoryPicker:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            defaults.simulatorDirectory_cde = panel.URL;
            self.simulatorDirectoryPopUpButton.URL = defaults.simulatorDirectory_cde;
        }
    }];
}

- (IBAction)showBuildDirectoryPicker:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            defaults.buildProductsDirectory_cde = panel.URL;
            self.buildDirectoryPopUpButton.URL = defaults.buildProductsDirectory_cde;
        }
    }];
}

@end
