#import "NSBundle+CDEModelFinder.h"
#import "NSManagedObjectModel-CDEAdditions.h"
#import "CDEModelChooserItem.h"

@implementation NSBundle (CDEModelFinder)

#pragma mark - Finding Models
- (NSArray *)modelChooserItems_cde {
    NSDirectoryEnumerator *enumerator = [[NSFileManager new] enumeratorAtPath:self.bundleURL.path];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSMutableArray *result = [NSMutableArray new];
    for(NSString *relativePath in enumerator) {
        NSString *absolutePath = [self.bundleURL.path stringByAppendingPathComponent:relativePath];
        NSString *UTI = [workspace typeOfFile:absolutePath error:NULL];
        if(UTI == nil) {
            continue;
        }
        
        BOOL conformsTo = [workspace type:UTI conformsToType:@"com.apple.xcode.mom"];
        if(conformsTo == NO) {
            continue;
        }
        
        NSString *titleForDisplay = relativePath;
        
        NSManagedObjectModel *originalModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:absolutePath]];
        
        CDEModelChooserItem *item = [[CDEModelChooserItem alloc] initWithTitleForDisplay:titleForDisplay
                                                                                     URL:[NSURL fileURLWithPath:absolutePath]
                                                                      managedObjectModel:originalModel.transformedManagedObjectModel_cde];
        if(item == nil) {
            continue;
        }
        
        [result addObject:item];
    }
    return result;
}

@end
