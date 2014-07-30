#import "CDERelationshipsViewControllerItem.h"

@implementation CDERelationshipsViewControllerItem

#pragma mark - Creating
- (instancetype)initWithRelationship:(NSRelationshipDescription *)relationship managedObject:(NSManagedObject *)managedObject {
    NSParameterAssert(relationship);
    NSParameterAssert(managedObject);
    
    self = [super init];
    if(self) {
        self.relationshipDescription = relationship;
        self.managedObject = managedObject;
    }
    return self;
}

- (instancetype)init {
    return [self initWithRelationship:nil managedObject:nil];
}

#pragma mark - Properties
- (NSImage *)imageRepresentingRelationshipType {
    NSString *imageName = self.relationshipDescription.isToMany ? @"Relationship-ToMany" : @"Relationship-ToOne";
    return [NSImage imageNamed:imageName];
}

- (NSUInteger)numberOfRelatedObjects {
    if(self.relationshipDescription.isToMany) {
        NSString *keyPath = [self.relationshipDescription.name stringByAppendingString:@".@count"];
        return [[self.managedObject valueForKeyPath:keyPath] unsignedIntegerValue];
    }
    // to-one
    id relatedObject = [self.managedObject valueForKey:self.relationshipDescription.name];
    return relatedObject == nil ? 0 : 1;
}

@end

