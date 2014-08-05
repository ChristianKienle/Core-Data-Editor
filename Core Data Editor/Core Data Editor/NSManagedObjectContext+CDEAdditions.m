#import "NSError+CDEValidation.h"

@implementation NSManagedObjectContext (CDEAdditions)

#pragma mark - Make a Managed Object Valid
- (void)makeManagedObjectValid:(NSManagedObject *)managedObject {
    NSLog(@"Making Object Valid: %@", managedObject.objectID.URIRepresentation.lastPathComponent);
    // Get the validation errors
    NSMutableOrderedSet *potentialInvalidObjects = [NSMutableOrderedSet orderedSet];
    NSArray *errors = managedObject.validationErrors_cde;
    NSLog(@"%lu validation errors", errors.count);

    for(NSError *error in errors) {
        NSString *propertyName = error.userInfo[NSValidationKeyErrorKey];
        if(propertyName == nil) {
            continue;
        }
        NSEntityDescription *entity = error.entityDescription_cde;
        NSPropertyDescription *property = [entity propertiesByName][propertyName];
        if(property == nil) {
            continue;
        }
        if(property.isRelationshipDescription_cde) {
            NSRelationshipDescription *relation = (NSRelationshipDescription *)property;
            if(relation.isToOne_cde) {
                NSAssert(!relation.isOptional, @"Invalid State: Relation should be mandatory");
                NSManagedObject *relatedObject = [NSEntityDescription insertNewObjectForEntityForName:relation.destinationEntity.name inManagedObjectContext:self];
                [managedObject setValue:relatedObject forKey:relation.name];
                [potentialInvalidObjects addObject:relatedObject];
                NSLog(@"     repaired error for %@.", propertyName);
            } else {
                NSUInteger minCount = relation.minCount;
                id mutableRelatedObjects = [[managedObject valueForKey:relation.name] mutableCopy];
                while(minCount--) {
                    NSManagedObject *relatedObject = [NSEntityDescription insertNewObjectForEntityForName:relation.destinationEntity.name inManagedObjectContext:self];
                    [mutableRelatedObjects addObject:relatedObject];
                    [managedObject setValue:mutableRelatedObjects forKey:relation.name];
                    [potentialInvalidObjects addObject:relatedObject];
                }
                NSLog(@"     repaired error for %@.", propertyName);

            }
        }
    }
    for(NSManagedObject *potentialInvalidObject in potentialInvalidObjects) {
        [self makeManagedObjectValid:potentialInvalidObject];
    }
}

@end
