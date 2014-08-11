#import <Foundation/Foundation.h>

@interface NSURL (CDEAdditions)

#pragma mark - Bookmarks (Convenience)
+ (NSURL *)URLByResolvingBookmarkData:(NSData *)data error_cde:(NSError **)error;
- (NSData *)bookmarkDataAndGetError_cde:(NSError **)error;

#pragma mark - UTI
- (NSString *)typeOfFileURLAndGetError_cde:(NSError **)error;
- (BOOL)isCompiledManagedObjectModelFile_cde;
- (BOOL)isPublicDataFile_cde;

#pragma mark - App Specific URLs
+ (instancetype)URLForWebsite_cde;
+ (instancetype)URLForCreateProjectTutorial_cde;
+ (instancetype)URLForSupportWebsite_cde;

@end

@interface NSURL (CDESQLiteAdditions)
- (BOOL)isSQLiteURL_cde;
- (BOOL)isSQLiteStoreURL_cde;
@end