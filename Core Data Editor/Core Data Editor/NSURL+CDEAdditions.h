#import <Foundation/Foundation.h>

@interface NSURL (CDEAdditions)

#pragma mark - Bookmarks (Convenience)
+ (NSURL *)URLByResolvingBookmarkData:(NSData *)data error_cde:(NSError **)error;
- (NSData *)bookmarkDataAndGetError_cde:(NSError **)error;

#pragma mark - UTI
- (NSString *)typeOfFileURLAndGetError_cde:(NSError **)error;
/**
 * Return the Application name if the NSURL contains it. nil if not found
 * Example:
 *  Input:  /iPhone Simulator/7.1/Applications/412F2A6B-0F54-4F98-AE1B-DFE99E057DB1/Example.app/v1.momd/v5.mom
 *  Output: 412F2A6B-0F54-4F98-AE1B-DFE99E057DB1
 *
 * @return NSString*
 */
- (NSString *)appFolderName_cde;
- (BOOL)isCompiledManagedObjectModelFile_cde;

#pragma mark - App Specific URLs
+ (instancetype)URLForWebsite_cde;
+ (instancetype)URLForCreateProjectTutorial_cde;
+ (instancetype)URLForSupportWebsite_cde;

@end

@interface NSURL (CDESQLiteAdditions)
- (BOOL)isSQLiteURL_cde;
@end