#import "CDERequestDataCoordinator.h"

@interface CDERequestDataCoordinator ()

#pragma mark - For Subclassers
// The default implementation returns columns for supported attributes, relationships and a column for the objectID
@property (nonatomic, copy, readwrite) NSArray *tableColumns;

@end
