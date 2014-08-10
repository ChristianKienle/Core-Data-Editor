#import <Foundation/Foundation.h>

@interface NSDirectoryEnumerator (ProjectBrowser)

- (void)getMetadataByStorePath:(NSDictionary **)metadataByStorePath modelByModelPath:(NSDictionary **)modelByModelPath;

@end

