#import "NSPropertyDescription+CDEAdditions.h"

@implementation NSPropertyDescription (CDEAdditions)

#pragma mark - Convenience
- (BOOL)isAttributeDescription_cde {
    @throw [NSException exceptionWithName:@"CDENotImplemented" reason:nil userInfo:nil];
}

- (BOOL)isRelationshipDescription_cde {
    @throw [NSException exceptionWithName:@"CDENotImplemented" reason:nil userInfo:nil];
}

- (NSString *)nameForDisplay_cde {
    return [self.name humanReadableStringAccordingToUserDefaults_cde];
}

@end
