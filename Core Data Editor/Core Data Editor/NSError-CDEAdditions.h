#import <Foundation/Foundation.h>

@interface NSError (CDEAdditions)

#pragma mark Creating
+ (id)newErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription localizedRecoverySuggestion_cde:(NSString *)localizedFailureReason;

@end
