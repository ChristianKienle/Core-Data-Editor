#import "NSDirectoryEnumerator+ProjectBrowser.h"
#import "NSURL+CDEAdditions.h"



@implementation NSDirectoryEnumerator (ProjectBrowser)

- (void)getMetadataByStorePath:(NSDictionary **)outMetadataByStorePath modelByModelPath:(NSDictionary **)outModelByModelPath {
    NSMutableDictionary *metadataByStorePath = [NSMutableDictionary new];
    NSMutableDictionary *modelByModelPath = [NSMutableDictionary new];

    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    for(NSURL *URL in self) {
        NSError *error = nil;
        NSString *UTI = [workspace typeOfFile:URL.path error:&error];
        if(UTI == nil) {
            NSLog(@"Failed to determine UTI: %@", error);
            continue;
        }
        BOOL isModel = [workspace type:UTI conformsToType:@"com.apple.xcode.mom"];
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
        
        BOOL isData = [workspace type:UTI conformsToType:@"public.data"];
        if(isData == NO) {
            continue;
        }
        
        if([URL isSQLiteURL_cde] == NO) {
            continue;
        }
        
        error = nil;
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
