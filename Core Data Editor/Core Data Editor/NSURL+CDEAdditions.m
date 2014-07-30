#import "NSURL+CDEAdditions.h"

@implementation NSURL (CDEAdditions)

#pragma mark - Bookmarks (Convenience)
+ (NSURL *)URLByResolvingBookmarkData:(NSData *)data error_cde:(NSError **)error {
    NSParameterAssert(data);
    
    return [NSURL URLByResolvingBookmarkData:data
                                     options:NSURLBookmarkResolutionWithSecurityScope
                               relativeToURL:nil
                         bookmarkDataIsStale:NULL
                                       error:error];
}

- (NSData *)bookmarkDataAndGetError_cde:(NSError **)error {
    NSError *localError = nil;
    NSURL *pathOnlyURL = [NSURL fileURLWithPath:[self path]];
    NSData *result = [pathOnlyURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                    includingResourceValuesForKeys:nil
                                     relativeToURL:nil
                                             error:&localError];
    if(result == nil) {
        if(error != NULL) {
            *error = localError;
        }
        return nil;
    }
    return result;
}

#pragma mark - UTI
- (NSString *)typeOfFileURLAndGetError_cde:(NSError **)error {
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    return [workspace typeOfFile:self.path error:error];
}

- (BOOL)isCompiledManagedObjectModelFile_cde {
    NSError *error = nil;
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSString *type = [self typeOfFileURLAndGetError_cde:&error];
    if(type == nil) {
        NSLog(@"Error in %@: %@", NSStringFromSelector(_cmd), error);
        return NO;
    }
    return [workspace type:type conformsToType:@"com.apple.xcode.mom"];
}

#pragma mark - App Specific URLs
+ (instancetype)URLForWebsite_cde {
    return [self URLWithString:[NSBundle mainBundle].infoDictionary[@"CDEWebsiteURL"]];
}

+ (instancetype)URLForCreateProjectTutorial_cde {
    return [self URLWithString:[NSBundle mainBundle].infoDictionary[@"CDECreateProjectTutorialURL"]];
}

+ (instancetype)URLForSupportWebsite_cde {
    return [self URLWithString:[NSBundle mainBundle].infoDictionary[@"CDECustomerSupportURL"]];
}

+ (instancetype)URLForVersionCheck_cde {
    return [self URLWithString:[NSBundle mainBundle].infoDictionary[@"CDECurrentVersionPath"]];
}

@end

@implementation NSURL (CDESQLiteAdditions)

- (BOOL)isSQLiteURL_cde {
  if(self.isFileURL == NO) {
    return NO;
  }
  NSError *error = nil;
  NSData *contents = [NSData dataWithContentsOfURL:self options:NSDataReadingMappedAlways error:&error];
  if(contents == nil) {
    //NSLog(@"error reading file %@: %@.", self, error);
    return NO;
  }
  if(contents.length < 16) {
    return NO;
  }
  NSData *header = [contents subdataWithRange:NSMakeRange(0, 16)];
  NSString *headerStringValue = [[NSString alloc] initWithData:header encoding:NSUTF8StringEncoding];
  if(headerStringValue == nil) {
    return NO;
  }
  return [headerStringValue isEqualToString:@"SQLite format 3\0"];
}
@end