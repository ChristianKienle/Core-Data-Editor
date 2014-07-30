#import <Cocoa/Cocoa.h>

// see: file:///Users/cmk/Projects/Products/CoreDataEditor
@class CDEConfiguration;
@interface CDEDocument : NSPersistentDocument

#pragma mark - Should only be used by the App Delegate
- (CDEConfiguration *)createConfiguration;
- (BOOL)setupAndStartAccessingConfigurationRelatedURLsAndGetError:(NSError **)error;

@end
