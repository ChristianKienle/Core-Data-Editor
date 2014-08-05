#import <Foundation/Foundation.h>

@interface NSManagedObjectModel (CDEAdditions)

#pragma mark - Creating
+ (BOOL)canInitWithContentsOfURL:(NSURL *)URL error_cde:(NSError **)error;

#pragma mark - Transforming
- (NSManagedObjectModel *)transformedManagedObjectModel_cde;

#pragma mark - Compatibility
- (BOOL)isCompatibleWithStoreAtURL:(NSURL *)URL error_cde:(NSError **)error;

@end
