#import "_CDEConfiguration.h"

@interface CDEConfiguration : _CDEConfiguration

#pragma mark - Getting the only Configuration object
+ (CDEConfiguration *)fetchedConfigurationInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error;
+ (BOOL)configurationExistsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error;

#pragma mark - Properties
@property (nonatomic, readonly, getter = isValid) BOOL isValid;

#pragma mark - Setting Bookmark Data in Batch
- (BOOL)setBookmarkDataWithApplicationBundleURL:(NSURL *)applicationBundleURL storeURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL error:(NSError **)error;

@end
