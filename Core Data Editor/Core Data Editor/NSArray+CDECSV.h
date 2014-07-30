#import <Foundation/Foundation.h>

@interface NSArray (CDECSV)
+ (instancetype)arrayWithContentsOfURL:(NSURL *)URL delimiter:(NSString *)delimiter error_cde:(NSError **)error;
+ (instancetype)arrayWithContentsOfCSVString:(NSString *)csvString delimiter:(NSString *)delimiter error_cde:(NSError **)error;
@end
