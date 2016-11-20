#import "PreferencesWC.h"

@interface PreferencesWC ()

@end

@implementation PreferencesWC

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - Showing the Preferences Window
- (void)showWithCompletionHandler:(CDEPreferencesWindowControllerCompletionHandler)handler {
//  self.completionHandler = handler;
//  [self showWindow:self];
}

- (void)showAutomaticProjectCreationPreferencesAndDisplayInfoSheetWithCompletionHandler:(CDEPreferencesWindowControllerCompletionHandler)handler {
  assert(false);

//  [self showAutomaticProjectCreationPreferencesWithCompletionHandler:handler];
//  double delayInSeconds = 0.5;
//  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//    NSString *identifier = NSStringFromClass([CDEPreferencesAutomaticProjectCreationViewController class]);
//    CDEPreferencesAutomaticProjectCreationViewController *viewController = (CDEPreferencesAutomaticProjectCreationViewController *)[self existingViewControllerForToolbarItemWithIdentifier:identifier];
//    [viewController displayInfoSheet];
//  });
}

- (void)showAutomaticProjectCreationPreferencesWithCompletionHandler:(CDEPreferencesWindowControllerCompletionHandler)handler {
  assert(false);

//  self.completionHandler = handler;
//  [self showWindow:self];
//  NSString *identifier = NSStringFromClass([CDEPreferencesAutomaticProjectCreationViewController class]);
//  CDEPreferencesAutomaticProjectCreationViewController *viewController = (CDEPreferencesAutomaticProjectCreationViewController *)[self existingViewControllerForToolbarItemWithIdentifier:identifier];
//  [self showViewController:viewController];
}


@end
