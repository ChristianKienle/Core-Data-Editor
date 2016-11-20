#import <Foundation/Foundation.h>

@interface NSDirectoryEnumerator (ProjectBrowser)

- (void)getMetadataByStorePath:(NSDictionary<NSString*, NSDictionary*> **)metadataByStorePath modelByModelPath:(NSDictionary<NSString*, NSManagedObjectModel*> **)modelByModelPath;

@end

