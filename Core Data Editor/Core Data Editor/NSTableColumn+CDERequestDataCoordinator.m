#import "NSTableColumn+CDERequestDataCoordinator.h"

@implementation NSTableColumn (CDERequestDataCoordinator)

#pragma mark - Identifying special Columns
- (BOOL)isObjectIDColumn_cde {
    return [self.identifier isEqualToString:@"objectID"];
}

@end

@implementation NSTableColumn (OrderedRelationshipRequestDataCoordinator)

- (BOOL)isOrderIndexColumn_cde {
    return [self.identifier isEqualToString:@"CDE_orderIndexColumn"];
}

@end
