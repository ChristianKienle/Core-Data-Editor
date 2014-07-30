#import "NSPersistentStoreCoordinator+CDEAdditions.h"
#import "NSURL+CDEAdditions.h"

@implementation NSPersistentStoreCoordinator (CDEAdditions)

- (NSPersistentStore *)addPersistentStoreWithType:(NSString *)storeType configuration:(NSString *)configuration URL:(NSURL *)storeURL options:(NSDictionary *)options error_cde:(NSError **)error {
  // We have a store type: Go the usual path
  if(storeType != nil) {
    return [self addPersistentStoreWithType:storeType configuration:configuration URL:storeURL options:options error:error];
  }
  
  // We have no store type: We have to 'guess' it in the least "invasive" manner...
  if(storeURL == nil) {
    NSLog(@"storeURL is nil: Cannot add persistent store.");
    return nil;
  }
  
  // 1. Look at the first few bytes of the file to determine if it is a SQLite db
  BOOL isSQLite = [storeURL isSQLiteURL_cde];
  if(isSQLite) {
    return [self addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:storeURL options:options error:error];
  }
  
  // 2. Our next guess: NSBinaryStoreType (because it is available on iOS)
  NSError *addStoreError = nil;
  NSPersistentStore *binaryStore = [self addPersistentStoreWithType:NSBinaryStoreType configuration:configuration URL:storeURL options:options error:&addStoreError];
  if(binaryStore != nil) {
    return binaryStore;
  }
  
  NSLog(@"CDE %@ guessed NSBinaryStoreType for store at %@. Guess was wrong: %@", NSStringFromSelector(_cmd), storeURL, addStoreError);
  
  // 3. Our next guess: NSXMLStoreType
  addStoreError = nil;
  NSPersistentStore *XMLStore = [self addPersistentStoreWithType:NSXMLStoreType configuration:configuration URL:storeURL options:options error:&addStoreError];
  if(XMLStore != nil) {
    return XMLStore;
  }
  
  NSLog(@"CDE %@ guessed NSXMLStoreType for store at %@. Guess was wrong: %@", NSStringFromSelector(_cmd), storeURL, addStoreError);
  
  // 4. There is nothing more to guess...
  return nil;
}

@end
