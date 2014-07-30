#import "NSRelationshipDescription+CDEAdditions.h"

@implementation NSRelationshipDescription (CDEAdditions)
- (BOOL)isToOne_cde {
    return !self.isToMany;
}
- (BOOL)isManyToMany_cde {
    return self.isToMany && self.inverseRelationship.isToMany;
}

#pragma mark - Convenience
- (BOOL)isAttributeDescription_cde {
    return NO;
}

- (BOOL)isRelationshipDescription_cde {
    return YES;
}

@end
