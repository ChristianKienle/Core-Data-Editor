#import <Cocoa/Cocoa.h>

// see: file:///Users/cmk/Projects/Products/CoreDataEditor
@class CDEConfiguration;
@interface CDEDocument : NSDocument

#pragma mark - Should only be used by the App Delegate
- (CDEConfiguration *)createConfiguration;

@end
