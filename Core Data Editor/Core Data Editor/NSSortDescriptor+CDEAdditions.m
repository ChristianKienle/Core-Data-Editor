#import "NSSortDescriptor+CDEAdditions.h"

@implementation NSSortDescriptor (CDEAdditions)

#pragma mark - Getting Sort Descriptors
+ (instancetype)newSortDescriptorForObjectIDColumn_cde {
    return [NSSortDescriptor sortDescriptorWithKey:@"objectID" ascending:NO comparator:^NSComparisonResult(NSManagedObjectID *left, NSManagedObjectID *right) {
        NSString *leftID = [left.URIRepresentation lastPathComponent];
        NSString *rightID = [right.URIRepresentation lastPathComponent];
        return [leftID localizedStandardCompare:rightID];
    }];
}

@end
