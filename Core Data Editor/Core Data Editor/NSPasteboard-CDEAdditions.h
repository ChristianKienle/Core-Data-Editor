#import <Foundation/Foundation.h>

@interface NSPasteboard (CDEAdditions)

#pragma mark Getting URLs from the Pasteboard
- (NSArray *)cde_URLs;
- (NSURL *)cde_URL;

@end
