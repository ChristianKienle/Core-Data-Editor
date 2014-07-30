#import <Cocoa/Cocoa.h>

@interface CDEProjectBrowserWindowController : NSWindowController

#pragma mark - Working with the project browser
- (void)showWithProjectDirectoryURL:(NSURL *)projectDirectoryURL;
- (void)updateProjectDirectoryURL:(NSURL *)projectDirectoryURL;

@end
