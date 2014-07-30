#import <Cocoa/Cocoa.h>

typedef void(^CDEPreferencesWindowControllerCompletionHandler)(void);

@interface CDEPreferencesWindowController : NSWindowController

#pragma mark - Showing the Preferences Window
- (void)showWithCompletionHandler:(CDEPreferencesWindowControllerCompletionHandler)handler;
- (void)showAutomaticProjectCreationPreferencesAndDisplayInfoSheetWithCompletionHandler:(CDEPreferencesWindowControllerCompletionHandler)handler;
- (void)showAutomaticProjectCreationPreferencesWithCompletionHandler:(CDEPreferencesWindowControllerCompletionHandler)handler;

@end
