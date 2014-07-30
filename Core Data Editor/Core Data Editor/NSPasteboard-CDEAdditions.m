#import "NSPasteboard-CDEAdditions.h"

@implementation NSPasteboard (CDEAdditions)

#pragma mark Getting URLs from the Pasteboard
- (NSArray *)cde_URLs {
   NSArray *classes = @[[NSURL class]];
   NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @YES};
   NSArray *fileURLs = [self readObjectsForClasses:classes options:options];
   if(fileURLs == nil) {
      return @[];
   }
   return fileURLs;
}

- (NSURL *)cde_URL {
   return [[self cde_URLs] lastObject];
}

@end
