#import <Foundation/Foundation.h>
#import "SQLiteDatabase.h"

#include <sqlite3.h>

static int callback(void *userInfo, int numberOfColumns, char **rowContent, char **columnNames) {
    NSMutableArray *rows = (__bridge NSMutableArray *)(userInfo);
    NSMutableDictionary *row = [NSMutableDictionary new];
    for(int columnIndex=0; columnIndex<numberOfColumns; columnIndex++) {
        NSString *column = [[NSString alloc] initWithUTF8String:columnNames[columnIndex]];
        char *rawValue = rowContent[columnIndex];
        if(rawValue == NULL) {
            continue;
        }
        
        NSString *value = [[NSString alloc] initWithUTF8String:rawValue];
        row[column] = value;
    }
    [rows addObject:row];
    return 0;
}

@interface SQLiteDatabase ()

#pragma mark - Interacting with the Database
@property (nonatomic, readwrite, copy) NSURL *URL;

#pragma mark - Properties
@property (assign) sqlite3 *database;
@end

@implementation SQLiteDatabase : NSObject

#pragma mark - Creating
- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if(self) {
        self.URL = URL;
    }
    return self;
}

+ (instancetype)newSQLiteDatabaseWithURL:(NSURL *)URL {
    return [[self alloc] initWithURL:URL];
}

- (instancetype)init {
    return nil; // throw exception
}

#pragma mark - Interacting with the Database
- (BOOL)open {
    sqlite3 *db;
    NSString *databasePath = self.URL.absoluteString;
    int status = sqlite3_open([databasePath UTF8String], &db);
    if(status) {
        NSLog(@"Can't open database: %s\n", sqlite3_errmsg(db));
        [self close];
        return NO;
    }
    self.database = db;
    return YES;
}
- (void)close {
    NSParameterAssert(self.database != NULL);
    sqlite3_close(self.database);
    self.database = NULL;
}
- (NSArray *)resultForQuery:(NSString *)query {
    NSParameterAssert(self.database != NULL);
    NSParameterAssert(query != nil);
    char *errorMessage = 0;

    NSMutableArray *rows = [NSMutableArray new];
    int status = sqlite3_exec(self.database, [query UTF8String], callback, (__bridge void *)(rows), &errorMessage);
    if(status != SQLITE_OK) {
        NSLog(@"SQL error: %s\n", errorMessage);
        sqlite3_free(errorMessage);
        return nil;
    }

    return rows;
}

@end