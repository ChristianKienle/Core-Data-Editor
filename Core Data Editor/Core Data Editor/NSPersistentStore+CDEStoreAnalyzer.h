#import <CoreData/CoreData.h>

@interface NSPersistentStore (CDEStoreAnalyzer)

#pragma mark - Getting the Type of a Store
// Returns nil if no store type could be determined
+ (NSString *)typeOfPersistentStoreAtURL_cde:(NSURL *)storeURL;

@end
