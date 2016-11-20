#import "NSError-CDEAdditions.h"

@implementation NSError (CDEAdditions)
#pragma mark Creating
+ (id)newErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription localizedRecoverySuggestion_cde:(NSString *)localizedRecoverySuggestion {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if(localizedDescription != nil) {
        userInfo[NSLocalizedDescriptionKey] = localizedDescription;
    }
    
    if(localizedRecoverySuggestion != nil) {
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = localizedRecoverySuggestion;
    }
    
    return [self errorWithDomain:@"de.christian-kienle.core-data-editor" code:code userInfo:userInfo];
}

@end
