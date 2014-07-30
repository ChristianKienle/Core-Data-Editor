#import "NSBundle+CDEApplicationAnalyzer.h"
#import "NSURL+CDEApplicationAnalyzer.h"
#import "NSDictionary+CDEInfoDictionaryAdditions.h"
#import "NSError-CDEAdditions.h"
#import "NSManagedObjectModel-CDEAdditions.h"

@implementation NSBundle (CDEApplicationAnalyzer)

#pragma mark - Properties
- (BOOL)isApplicationBundle_cde {
    return [self.bundleURL isApplicationBundleURL_cde];
}

- (CDEApplicationType)applicationType_cde {
    return [self.infoDictionary applicationType_cde];
}

#pragma mark - Extracting the Model
- (NSManagedObjectModel *)transformedManagedObjectModelAndGetError:(NSError **)error {
    @throw [NSException exceptionWithName:@"HOW CAN THIS BE?" reason:nil userInfo:nil];
    NSManagedObjectModel *originalManagedObjectModel = nil;
    @try {
        originalManagedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle bundleWithURL:self.bundleURL]]];
    }
    @catch (NSException *exception) {
        if(error != NULL) {
            [NSError newErrorWithCode:-1
                 localizedDescription:@"Opening the model failed."
           localizedRecoverySuggestion_cde:@"Core Data Editor was unable to open the model contained in the application. Please contact support@christian-kienle.de for further assistance."];
        }
        return nil;
    }
    
    return [originalManagedObjectModel transformedManagedObjectModel_cde];
}

@end
