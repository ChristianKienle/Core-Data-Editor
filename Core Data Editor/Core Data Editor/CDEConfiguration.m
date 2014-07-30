#import "CDEConfiguration.h"
#import "NSURL+CDEAdditions.h"

@interface CDEConfiguration ()
@end

@implementation CDEConfiguration

#pragma mark - Properties

#pragma mark - Getting the only Configuration object
+ (CDEConfiguration *)fetchedConfigurationInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    NSArray *fetchedConfigurations = [managedObjectContext executeFetchRequest:fetchRequest error:error];
    CDEConfiguration *configuration = [fetchedConfigurations lastObject];
    return configuration;
}

+ (BOOL)configurationExistsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    NSUInteger count = [managedObjectContext countForFetchRequest:fetchRequest error:error];

    if(count == NSNotFound) {
        return NO;
    }
    
    return (count == 1);
}

+ (NSSet *)keyPathsForValuesAffectingIsValid {
    return [NSSet setWithArray:@[CDEConfigurationAttributes.modelBookmarkData, CDEConfigurationAttributes.storeBookmarkData]];
}

- (BOOL)isValid {
    if(self.modelBookmarkData == nil || self.storeBookmarkData == nil) {
        return NO;
    }
    return YES;
}

#pragma mark - Setting Bookmark Data in Batch
- (BOOL)setBookmarkDataWithApplicationBundleURL:(NSURL *)applicationBundleURL storeURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL error:(NSError **)error {
    NSParameterAssert(storeURL);
    NSParameterAssert(modelURL);
    
    // Application Bundle URL is optional
    
    NSError *bookmarkError = nil;
    NSData *storeData = [storeURL bookmarkDataAndGetError_cde:&bookmarkError];
    
    if(storeData == nil) {
        NSLog(@"Error: %@", bookmarkError);
        if(error != NULL) {
            *error = bookmarkError;
        }
        return NO;
    }
    
    self.storeBookmarkData = storeData;
    
    bookmarkError = nil;
    NSData *modelData = [modelURL bookmarkDataAndGetError_cde:&bookmarkError];
    
    if(modelData == nil) {
        NSLog(@"Error: %@", bookmarkError);
        if(error != NULL) {
            *error = bookmarkError;
        }
        return NO;
    }
    
    self.modelBookmarkData = modelData;
    
    if(applicationBundleURL != nil) {
        bookmarkError = nil;
        NSData *applicationData = [applicationBundleURL bookmarkDataAndGetError_cde:&bookmarkError];
        
        if(applicationData == nil) {
            NSLog(@"Error: %@", bookmarkError);
            if(error != NULL) {
                *error = bookmarkError;
            }
            return NO;
        }
        self.applicationBundleBookmarkData = applicationData;
    }

    return YES;
}

@end
