#import <Cocoa/Cocoa.h>

@interface NSTableColumn (CDERequestDataCoordinator)

#pragma mark - Identifying special Columns
- (BOOL)isObjectIDColumn_cde;

@end

@interface NSTableColumn (OrderedRelationshipRequestDataCoordinator)

#pragma mark - Identifying special Columns
- (BOOL)isOrderIndexColumn_cde;

@end