#import "NSURL+CDEAdditions.h"
#import "SQLiteDatabase.h"

@implementation NSURL (CDEAdditions)

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

- (BOOL)isPublicDataFile_cde {
    NSError *error = nil;
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSString *type = [self typeOfFileURLAndGetError_cde:&error];
    if(type == nil) {
        NSLog(@"Error in %@: %@", NSStringFromSelector(_cmd), error);
        return NO;
    }
    return [workspace type:type conformsToType:@"public.data"];
    
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

@end

@implementation NSURL (CDESQLiteAdditions)

- (BOOL)isSQLiteURL_cde {
    if(self.isFileURL == NO) {
        return NO;
    }
    NSError *error = nil;
    NSData *contents = [NSData dataWithContentsOfURL:self options:NSDataReadingMappedAlways error:&error];
    if(contents == nil) {
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

- (BOOL)isSQLiteStoreURL_cde {
    SQLiteDatabase *database = [SQLiteDatabase newSQLiteDatabaseWithURL:self];
    if([database open] == NO) {
        return NO;
    }
    NSString *query = @"select name from sqlite_master";
    NSArray *rows = [database resultForQuery:query];
    if(rows == nil) {
        [database close];
        return NO;
    }
    BOOL primaryKeyTableFound = NO;
    for(NSDictionary *row in rows) {
        if(primaryKeyTableFound == NO) {
            primaryKeyTableFound = [row[@"name"] isEqualToString:@"Z_PRIMARYKEY"];
        }
    }
    [database close];
    return primaryKeyTableFound;
}

@end
