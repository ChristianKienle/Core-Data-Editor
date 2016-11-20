#import <Foundation/Foundation.h>

@interface NSPasteboard (CDEAdditions)

#pragma mark Getting URLs from the Pasteboard
- (NSArray<NSURL*> *)cde_URLs;
- (NSURL *)cde_URL;

@end
