#import "CDEToOneRelationshipTableCellView.h"
#import "CDEManagedObjectsRequest.h"

@interface CDEManagedObjectsRequest (CDEToOneRelationshipTableCellView)

- (NSManagedObject *)destinationObject;

@end

@implementation CDEManagedObjectsRequest (CDEToOneRelationshipTableCellView)

- (NSManagedObject *)destinationObject {
    return [self.managedObject valueForKey:self.relationshipDescription.name];
}

@end

@implementation CDEToOneRelationshipTableCellView

- (void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];
    
}
@end
