#import "NSPersistentStore+CDEStoreAnalyzer.h"

@implementation NSPersistentStore (CDEStoreAnalyzer)

#pragma mark - Getting the Type of a Store
// Returns nil if no store type could be determined
+ (NSString *)typeOfPersistentStoreAtURL_cde:(NSURL *)storeURL {
  NSError *error = nil;
  @try {
    NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:storeURL error:&error];
    if(metadata == nil) {
      NSLog(@"Failed to determine store metadata: %@", error);
      return nil;
    }
    NSString *type = metadata[NSStoreTypeKey];
    NSAssert(type != nil, @"The keys guaranteed to be in this dictionary are NSStoreTypeKey and NSStoreUUIDKey.");
    return type;
  }
  @catch (NSException *exception) { }
  return nil;
}

@end
