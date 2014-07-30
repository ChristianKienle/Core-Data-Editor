#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (CDEAdditions)

- (NSPersistentStore *)addPersistentStoreWithType:(NSString *)storeType configuration:(NSString *)configuration URL:(NSURL *)storeURL options:(NSDictionary *)options error_cde:(NSError **)error;

@end
