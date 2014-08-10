#import "NSDirectoryEnumerator+ProjectBrowser.h"
#import "NSURL+CDEAdditions.h"



@implementation NSDirectoryEnumerator (ProjectBrowser)

- (void)getMetadataByStorePath:(NSDictionary **)outMetadataByStorePath modelByModelPath:(NSDictionary **)outModelByModelPath {
    NSMutableDictionary *metadataByStorePath = [NSMutableDictionary new];
    NSMutableDictionary *modelByModelPath = [NSMutableDictionary new];

    for(NSURL *URL in self) {
        

        BOOL isModel = [URL isCompiledManagedObjectModelFile_cde];
        if(isModel) {
            @try {
                NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:URL];
                if(model == nil) {
                    continue;
                }
                NSManagedObjectModel *transformedModel = model.transformedManagedObjectModel_cde;
                if(transformedModel == nil) {
                    continue;
                }
                modelByModelPath[URL.path] = transformedModel;
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            
            continue;
        }
        
        BOOL isData = [URL isPublicDataFile_cde];
        if(isData == NO) {
            continue;
        }
        
        if([URL isSQLiteURL_cde] == NO) {
            continue;
        }
        
        NSError *error;
        NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:URL error:&error];
        if(metadata == nil) {
            continue;
        }
        metadataByStorePath[URL.path] = metadata;
    }

    if(outMetadataByStorePath != NULL) {
        *outMetadataByStorePath = metadataByStorePath;
    }
    if(outModelByModelPath != NULL) {
        *outModelByModelPath = modelByModelPath;
    }
}

@end
