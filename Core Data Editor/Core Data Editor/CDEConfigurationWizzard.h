#import <Cocoa/Cocoa.h>

typedef void (^CDEConfigurationWizzardCompletionHandler)(BOOL success, NSURL *applicationBundleURL, NSURL *storeURL, NSURL *modelURL);

@interface CDEConfigurationWizzard : NSWindowController 

#pragma mark Properties
@property (nonatomic, getter=isEditing) BOOL editing;

#pragma mark Running the Wizzard
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(CDEConfigurationWizzardCompletionHandler)handler;

- (void)beginSheetModalForWindow:(NSWindow *)window
            applicationBundleURL:(NSURL *)applicationBundleURL
                        storeURL:(NSURL *)storeURL
                        modelURL:(NSURL *)modelURL
               completionHandler:(CDEConfigurationWizzardCompletionHandler)handler;

@end
