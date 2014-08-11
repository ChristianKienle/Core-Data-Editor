// This class is a tiny SQLite wrapper. It is really tiny and not meant to be used
// for heavy lifting.

#import <Foundation/Foundation.h>

@interface SQLiteDatabase : NSObject

#pragma mark - Creating
- (instancetype)initWithURL:(NSURL *)URL;
+ (instancetype)newSQLiteDatabaseWithURL:(NSURL *)URL;

#pragma mark - Interacting with the Database
@property (nonatomic, readonly, copy) NSURL *URL;

- (BOOL)open;
- (void)close;
- (NSArray *)resultForQuery:(NSString *)query;

@end